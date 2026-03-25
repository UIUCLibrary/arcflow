# Traject configuration for indexing EAC-CPF creator records to Solr
#
# This config file processes EAC-CPF (Encoded Archival Context - Corporate Bodies,
# Persons, and Families) XML documents from ArchivesSpace archival_contexts endpoint.
#
# Usage:
#   bundle exec traject -u $SOLR_URL -c example_traject_config_eac_cpf.rb /path/to/agents/*.xml
#
# For production, copy this file to your arcuit gem as traject_config_eac_cpf.rb
#
# The EAC-CPF XML documents are retrieved directly from ArchivesSpace via:
#   /repositories/{repo_id}/archival_contexts/{agent_type}/{id}.xml

require 'traject'
require 'traject_plus'
require 'traject_plus/macros'
require 'time'

# Use TrajectPlus macros (provides extract_xpath and other helpers)
extend TrajectPlus::Macros

# EAC-CPF namespace - used consistently throughout this config
EAC_NS = { 'eac' => 'urn:isbn:1-931666-33-4' }

# Entity types - SINGLE SOURCE OF TRUTH
ENTITY_TYPES = ['corporate_entities', 'people', 'families']

# Pattern matching arcflow's creator file naming: creator_{entity_type}_{id}

CREATOR_ID_PATTERN = /^creator_(#{ENTITY_TYPES.join('|')})_\d+$/

settings do
  provide "solr.url", ENV['SOLR_URL'] || "http://localhost:8983/solr/blacklight-core"
  provide "solr_writer.commit_on_close", "true"
  provide "solr_writer.thread_pool", "8"
  provide "solr_writer.batch_size", "100"
  provide "processing_thread_pool", "4"
  
  # Use NokogiriReader for XML processing
  provide "reader_class_name", "Traject::NokogiriReader"
end

# Each record from reader
each_record do |record, context|
  context.clipboard[:is_creator] = true
end

# Solr uniqueKey - extract ID from filename using arcflow's creator_{entity_type}_{id} pattern
to_field 'id' do |record, accumulator, context|
  source_file = context.source_record_id || context.input_name
  if source_file
    id_from_filename = File.basename(source_file, '.xml')
    if id_from_filename =~ CREATOR_ID_PATTERN
      accumulator << id_from_filename
      context.logger.info("Using filename-based ID: #{id_from_filename}")
    else
      context.logger.error("Filename doesn't match expected pattern 'creator_{type}_{id}': #{id_from_filename}")
      context.skip!("Invalid ID format in filename")
    end
  else
    context.logger.error("No source filename available for record")
    context.skip!("Missing source filename")
  end
end

# Add is_creator boolean marker field
to_field 'is_creator' do |record, accumulator|
  accumulator << true
end

# # Record type
# to_field 'record_type' do |record, accumulator|
#   accumulator << 'creator'
# end

# Entity type (corporateBody, person, family)
to_field 'entity_type_ssi' do |record, accumulator|
  entity = record.xpath('//eac:cpfDescription/eac:identity/eac:entityType', EAC_NS).first
  accumulator << entity.text if entity
end

# Title/name fields - using ArcLight dynamic field naming convention
# _tesim = text, stored, indexed, multiValued (for full-text search)
# _ssm = string, stored, multiValued (for display)
# _ssi = string, stored, indexed (for faceting/sorting)
to_field 'title_tesim' do |record, accumulator|
  name = record.xpath('//eac:cpfDescription/eac:identity/eac:nameEntry/eac:part', EAC_NS)
  accumulator << name.map(&:text).join(' ') if name.any?
end

to_field 'title_ssm' do |record, accumulator|
  name = record.xpath('//eac:cpfDescription/eac:identity/eac:nameEntry/eac:part', EAC_NS)
  accumulator << name.map(&:text).join(' ') if name.any?
end

to_field 'title_filing_ssi' do |record, accumulator|
  name = record.xpath('//eac:cpfDescription/eac:identity/eac:nameEntry/eac:part', EAC_NS)
  if name.any?
    text = name.map(&:text).join(' ')
    # Remove leading articles and convert to lowercase for filing
    accumulator << text.gsub(/^(a|an|the)\s+/i, '').downcase
  end
end

# Dates of existence - using ArcLight standard field unitdate_ssm
# (matches what ArcLight uses for collection dates)
to_field 'unitdate_ssm' do |record, accumulator|
  # Try existDates element
  base_path = '//eac:cpfDescription/eac:description/eac:existDates'
  dates = record.xpath("#{base_path}/eac:dateRange/eac:fromDate | #{base_path}/eac:dateRange/eac:toDate | #{base_path}/eac:date", EAC_NS)
  if dates.any?
    from_date = record.xpath("#{base_path}/eac:dateRange/eac:fromDate", EAC_NS).first
    to_date = record.xpath("#{base_path}/eac:dateRange/eac:toDate", EAC_NS).first
    
    if from_date || to_date
      from_text = from_date ? from_date.text : ''
      to_text = to_date ? to_date.text : ''
      accumulator << "#{from_text}-#{to_text}".gsub(/^-|-$/, '')
    else
      # Single date
      dates.each { |d| accumulator << d.text }
    end
  end
end

# Biographical/historical note - using ArcLight conventions
# _tesim for searchable plain text
# _tesm for searchable HTML (text, stored, multiValued but not for display)
# _ssm for section heading display
to_field 'bioghist_tesim' do |record, accumulator|
  # Extract text from biogHist elements for full-text search
  bioghist = record.xpath('//eac:cpfDescription/eac:description/eac:biogHist//eac:p', EAC_NS)
  if bioghist.any?
    text = bioghist.map(&:text).join(' ')
    accumulator << text
  end
end

# Biographical/historical note - HTML
to_field 'bioghist_html_tesm' do |record, accumulator|
  # Extract HTML for searchable content (matches ArcLight's bioghist_html_tesm)
  bioghist = record.xpath('//eac:cpfDescription/eac:description/eac:biogHist//eac:p', EAC_NS)
  if bioghist.any?
    # Preserve inline EAC markup inside <eac:p> by serializing child nodes
    html = bioghist.map { |p| "<p>#{p.inner_html}</p>" }.join("\n")
    accumulator << html
  end
end

to_field 'bioghist_heading_ssm' do |record, accumulator|
  # Extract section heading (matches ArcLight's bioghist_heading_ssm pattern)
  heading = record.xpath('//eac:cpfDescription/eac:description/eac:biogHist//eac:head', EAC_NS).first
  accumulator << heading.text if heading
end

# Full-text search field
to_field 'text' do |record, accumulator|
  # Title
  name = record.xpath('//eac:cpfDescription/eac:identity/eac:nameEntry/eac:part', EAC_NS)
  accumulator << name.map(&:text).join(' ') if name.any?
  
  # Bioghist
  bioghist = record.xpath('//eac:cpfDescription/eac:description/eac:biogHist//eac:p', EAC_NS)
  accumulator << bioghist.map(&:text).join(' ') if bioghist.any?
end

# Related agents (from cpfRelation elements) for display parsing and debugging, stored as a single line
# 	"https://archivesspace-stage.library.illinois.edu/agents/corporate_entities/57|associative"
to_field 'related_agents_debug_ssim' do |record, accumulator|
  relations = record.xpath('//eac:cpfDescription/eac:relations/eac:cpfRelation', EAC_NS)
  relations.each do |rel|
    href = rel['href'] || rel['xlink:href']
    relation_type = rel['cpfRelationType']

    if href
      solr_id = aspace_uri_to_solr_id(href)
      if solr_id
        # Format: "solr_id|type"
        accumulator << "#{solr_id}|#{relation_type || 'unknown'}"
      end
    end
  end
end

# Related agents - ASpace URIs, in parallel array to match ids and types
to_field 'related_agent_uris_ssim' do |record, accumulator|
  relations = record.xpath('//eac:cpfDescription/eac:relations/eac:cpfRelation', EAC_NS)
  relations.each do |rel|
    href = rel['href'] || rel['xlink:href']
    accumulator << href if href
  end
end

# Related agents - Parallel array of relationship ids to match relationship types and uris
to_field 'related_agent_ids_ssim' do |record, accumulator|
  relations = record.xpath('//eac:cpfDescription/eac:relations/eac:cpfRelation', EAC_NS)
  relations.each do |rel|
    href = rel['href'] || rel['xlink:href']
    if href
      solr_id = aspace_uri_to_solr_id(href)  # CONVERT URI TO ID
      accumulator << solr_id if solr_id
    end
  end
end

# Related Agents - Parallel array of names to match relationship ids, uris and type
to_field 'related_agent_names_ssim' do |record, accumulator|
  relations = record.xpath('//eac:cpfDescription/eac:relations/eac:cpfRelation/eac:relationEntry', EAC_NS)
  relations.each do |rel|
    accumulator << rel.text
  end
end

# Related Agents - Parallel array of relationship types to match relationship ids and uris
to_field 'related_agent_relationship_types_ssim' do |record, accumulator|
  relations = record.xpath('//eac:cpfDescription/eac:relations/eac:cpfRelation', EAC_NS)
  relations.each do |rel|
    href = rel['href'] || rel['xlink:href']
    if href
      relation_type = rel['cpfRelationType'] || 'unknown'
      accumulator << relation_type  # NO deduplication - keeps array parallel
    end
  end
end

# Relationship types used for faceting,
to_field 'relationship_types_ssim' do |record, accumulator|
  relations = record.xpath('//eac:cpfDescription/eac:relations/eac:cpfRelation', EAC_NS)
  relations.each do |rel|
    relation_type = rel['cpfRelationType']
    accumulator << relation_type if relation_type && !accumulator.include?(relation_type)
  end
end

# Collections this creator is responsible for - EAD IDs injected by arcflow
# into <resourceRelation resourceRelationType="creatorOf"> elements as:
#   <descriptiveNote><p>ead_id:{ead_id}</p></descriptiveNote>
# Indexed as an array of EAD IDs (e.g., ["ALA.9.5.16"]) for bidirectional
# creator↔collection linking in Solr.
to_field 'creator_of_collection__collection_ids_ssim' do |record, accumulator|
  relations = record.xpath(
    '//eac:cpfDescription/eac:relations/eac:resourceRelation[@resourceRelationType="creatorOf"]',
    EAC_NS
  )
  relations.each do |rel|
    note = rel.xpath('eac:descriptiveNote/eac:p', EAC_NS).first
    if note && note.text =~ /\Aead_id:(.+)\z/
      accumulator << $1.strip
    end
  end
end

to_field 'creator_of_collection__collection_name_ssim' do |record, accumulator|
  relations = record.xpath(
    '//eac:cpfDescription/eac:relations/eac:resourceRelation[@resourceRelationType="creatorOf"]',
    EAC_NS
  )
  relations.each do |rel|
    note = rel.xpath('eac:descriptiveNote/eac:p', EAC_NS).first
    if note && note.text =~ /\Aead_id:(.+)\z/
      name = rel.xpath('eac:relationEntry', EAC_NS)
      accumulator << name.text
    end
  end
end


to_field 'creator_of_digital_object__do_ids_ssim' do |record, accumulator|
  relations = record.xpath(
    '//eac:cpfDescription/eac:relations/eac:resourceRelation[@resourceRelationType="creatorOf"]',
    EAC_NS
  )
  relations.each do |rel|
    href = rel['href'] || rel['xlink:href']
    if href.include? "digital_object"
      accumulator << href
    end
  end
end

to_field 'subject_of_digital_object__do_ids_ssim' do |record, accumulator|
  relations = record.xpath(
    '//eac:cpfDescription/eac:relations/eac:resourceRelation[@resourceRelationType="subjectOf"]',
    EAC_NS
  )
  relations.each do |rel|
    href = rel['href'] || rel['xlink:href']
    if href.include? "digital_object"
      accumulator << href
    end
  end
end


# Agent source URI (from original ArchivesSpace)
to_field 'agent_uri_ssi' do |record, accumulator|
  # Try to extract from control section or otherRecordId
  other_id = record.xpath('//eac:control/eac:otherRecordId[@localType="archivesspace_uri"]', EAC_NS).first
  if other_id
    accumulator << other_id.text
  end
end

# Timestamp
to_field 'timestamp' do |record, accumulator|
  accumulator << Time.now.utc.iso8601
end

# Log successful indexing
each_record do |record, context|
  record_id = record.xpath('//eac:control/eac:recordId', EAC_NS).first
  if record_id
    context.logger.info("Indexed creator: #{record_id.text}")
  end
end

# Helper to build and validate creator IDs
def build_creator_id(entity_type, id_number)
  creator_id = "creator_#{entity_type}_#{id_number}"
  unless creator_id =~ CREATOR_ID_PATTERN
    raise ArgumentError, "Invalid creator ID: #{creator_id} doesn't match pattern"
  end
  creator_id
end

# Helper to convert ArchivesSpace URI to Solr creator ID
def aspace_uri_to_solr_id(uri)
  return nil unless uri
  # Match: /agents/{type}/{id} or https://.../agents/{type}/{id}
  if uri =~ /agents\/(#{ENTITY_TYPES.join('|')})\/(\d+)/
    build_creator_id($1, $2)
  end
end