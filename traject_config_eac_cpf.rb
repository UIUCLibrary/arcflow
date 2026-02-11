# Traject configuration for indexing EAC-CPF creator records to Solr
#
# This config file processes EAC-CPF (Encoded Archival Context - Corporate Bodies,
# Persons, and Families) XML documents from ArchivesSpace archival_contexts endpoint.
#
# Usage:
#   bundle exec traject -u $SOLR_URL -c traject_config_eac_cpf.rb /path/to/agents/*.xml
#
# The EAC-CPF XML documents are retrieved directly from ArchivesSpace via:
#   /repositories/{repo_id}/archival_contexts/{agent_type}/{id}.xml

require 'traject'
require 'traject_plus'
require 'traject_plus/macros'

# Use TrajectPlus macros (provides extract_xpath and other helpers)
extend TrajectPlus::Macros

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

# Core identity field
# CRITICAL: The 'id' field is required by Solr's schema (uniqueKey)
# Must ensure this field is never empty or indexing will fail
#
# IMPORTANT: Real EAC-CPF from ArchivesSpace has empty <control/> element!
# Cannot rely on recordId being present. Must extract from filename or generate.
to_field 'id' do |record, accumulator, context|
  # Try 1: Extract from control/recordId (if present)
  record_id = record.xpath('//eac-cpf/control/recordId', 
                          'eac-cpf' => 'urn:isbn:1-931666-33-4').first
  record_id ||= record.xpath('//control/recordId').first
  
  if record_id && !record_id.text.strip.empty?
    accumulator << record_id.text.strip
  else
    # Try 2: Extract from source filename (most reliable for ArchivesSpace exports)
    # Filename format: creator_corporate_entities_584.xml or similar
    source_file = context.source_record_id || context.input_name
    if source_file
      # Remove .xml extension and any path
      id_from_filename = File.basename(source_file, '.xml')
      # Check if it looks valid (starts with creator_ or agent_)
      if id_from_filename =~ /^(creator_|agent_)/
        accumulator << id_from_filename
        context.logger.info("Using filename-based ID: #{id_from_filename}")
      else
        # Try 3: Generate from entity type and name
        entity_type = record.xpath('//identity/entityType').first&.text&.strip
        name_entry = record.xpath('//identity/nameEntry/part').first&.text&.strip
        
        if entity_type && name_entry
          # Create stable ID from type and name
          type_short = case entity_type
                      when 'corporateBody' then 'corporate'
                      when 'person' then 'person'
                      when 'family' then 'family'
                      else 'entity'
                      end
          name_id = name_entry.gsub(/[^a-z0-9]/i, '_').downcase[0..50] # Limit length
          generated_id = "creator_#{type_short}_#{name_id}"
          accumulator << generated_id
          context.logger.warn("Generated ID from name: #{generated_id}")
        else
          # Last resort: timestamp-based unique ID
          fallback_id = "creator_unknown_#{Time.now.to_i}_#{rand(10000)}"
          accumulator << fallback_id
          context.logger.error("Using fallback ID: #{fallback_id}")
        end
      end
    else
      # No filename available, generate from name
      entity_type = record.xpath('//identity/entityType').first&.text&.strip
      name_entry = record.xpath('//identity/nameEntry/part').first&.text&.strip
      
      if entity_type && name_entry
        type_short = case entity_type
                    when 'corporateBody' then 'corporate'
                    when 'person' then 'person'
                    when 'family' then 'family'
                    else 'entity'
                    end
        name_id = name_entry.gsub(/[^a-z0-9]/i, '_').downcase[0..50]
        generated_id = "creator_#{type_short}_#{name_id}"
        accumulator << generated_id
        context.logger.warn("Generated ID from name: #{generated_id}")
      else
        # Absolute last resort
        fallback_id = "creator_unknown_#{Time.now.to_i}_#{rand(10000)}"
        accumulator << fallback_id
        context.logger.error("Using fallback ID: #{fallback_id}")
      end
    end
  end
end

# Add is_creator marker field
to_field 'is_creator' do |record, accumulator|
  accumulator << 'true'
end

# Record type
to_field 'record_type' do |record, accumulator|
  accumulator << 'creator'
end

# Entity type (corporateBody, person, family)
to_field 'entity_type' do |record, accumulator|
  entity = record.xpath('//cpfDescription/identity/entityType', 
                       'eac-cpf' => 'urn:isbn:1-931666-33-4').first
  if entity
    accumulator << entity.text
  else
    # Fallback without namespace
    entity = record.xpath('//identity/entityType').first
    accumulator << entity.text if entity
  end
end

# Title/name fields - from authorized form of name
to_field 'title' do |record, accumulator|
  # Try with namespace
  name = record.xpath('//cpfDescription/identity/nameEntry/part', 
                     'eac-cpf' => 'urn:isbn:1-931666-33-4')
  if name.any?
    accumulator << name.map(&:text).join(' ')
  else
    # Fallback without namespace
    name = record.xpath('//identity/nameEntry/part')
    accumulator << name.map(&:text).join(' ') if name.any?
  end
end

to_field 'title_display' do |record, accumulator|
  name = record.xpath('//identity/nameEntry/part')
  accumulator << name.map(&:text).join(' ') if name.any?
end

to_field 'title_sort' do |record, accumulator|
  name = record.xpath('//identity/nameEntry/part')
  if name.any?
    text = name.map(&:text).join(' ')
    accumulator << text.gsub(/^(a|an|the)\s+/i, '').downcase
  end
end

# Dates of existence
to_field 'dates' do |record, accumulator|
  # Try existDates element
  dates = record.xpath('//existDates/dateRange/fromDate | //existDates/dateRange/toDate | //existDates/date')
  if dates.any?
    from_date = record.xpath('//existDates/dateRange/fromDate').first
    to_date = record.xpath('//existDates/dateRange/toDate').first
    
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

# Biographical/historical note - text content
to_field 'bioghist_text' do |record, accumulator|
  # Extract text from biogHist elements
  bioghist = record.xpath('//biogHist//p')
  if bioghist.any?
    text = bioghist.map(&:text).join(' ')
    accumulator << text
  end
end

# Biographical/historical note - HTML
to_field 'bioghist_html' do |record, accumulator|
  bioghist = record.xpath('//biogHist//p')
  if bioghist.any?
    html = bioghist.map { |p| "<p>#{p.text}</p>" }.join("\n")
    accumulator << html
  end
end

# Full-text search field
to_field 'text' do |record, accumulator|
  # Title
  name = record.xpath('//identity/nameEntry/part')
  accumulator << name.map(&:text).join(' ') if name.any?
  
  # Bioghist
  bioghist = record.xpath('//biogHist//p')
  accumulator << bioghist.map(&:text).join(' ') if bioghist.any?
end

# Related agents (from cpfRelation elements)
to_field 'related_agents_ssim' do |record, accumulator|
  relations = record.xpath('//cpfRelation')
  relations.each do |rel|
    # Get the related entity href/identifier
    href = rel['href'] || rel['xlink:href']
    relation_type = rel['cpfRelationType']
    
    if href
      # Store as: "uri|type" for easy parsing later
      accumulator << "#{href}|#{relation_type}"
    elsif relation_entry = rel.xpath('relationEntry').first
      # If no href, at least store the name
      name = relation_entry.text
      accumulator << "#{name}|#{relation_type}" if name
    end
  end
end

# Related agents - just URIs (for simpler queries)
to_field 'related_agent_uris_ssim' do |record, accumulator|
  relations = record.xpath('//cpfRelation')
  relations.each do |rel|
    href = rel['href'] || rel['xlink:href']
    accumulator << href if href
  end
end

# Relationship types
to_field 'relationship_types_ssim' do |record, accumulator|
  relations = record.xpath('//cpfRelation')
  relations.each do |rel|
    relation_type = rel['cpfRelationType']
    accumulator << relation_type if relation_type && !accumulator.include?(relation_type)
  end
end

# Agent source URI (from original ArchivesSpace)
to_field 'agent_uri' do |record, accumulator|
  # Try to extract from control section or otherRecordId
  other_id = record.xpath('//control/otherRecordId[@localType="archivesspace_uri"]').first
  if other_id
    accumulator << other_id.text
  end
end

# Timestamp
to_field 'timestamp' do |record, accumulator|
  accumulator << Time.now.utc.iso8601
end

# Document type marker
to_field 'document_type' do |record, accumulator|
  accumulator << 'creator'
end

# Log successful indexing
each_record do |record, context|
  record_id = record.xpath('//control/recordId').first
  if record_id
    context.logger.info("Indexed creator: #{record_id.text}")
  end
end
