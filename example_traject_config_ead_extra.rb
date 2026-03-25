# Example Traject extra config for EAD collection indexing.
# You can copy this file into Arclight (or a theme you have modifying Arclight,
# e.g., Arcuit):
# {arclight_dir}/lib/arcuit/traject/ead_extra_config.rb
#
# Any additional Traject commands you add to this file will be added to collection
# records in Arclight.
#
# This file shows the fields that arcflow injects into EAD XML to support:
# 1. Record group and sub-group categories
# 2. Solr ID for the creator records also created by arcflow
#
# GROUP + SUB-GROUP
# Arcflow adds <recordgroup> and <subgroup> elements directly after </did>
#   <recordgroup>ALA 52 — Library Periodicals Round Table</recordgroup>
#   <subgroup>ALA 52.2 — Publications</subgroup>
#
# CREATOR RECORDS
# Arcflow adds arcuit:creator_id attributes to origination name elements
# using a custom namespace to avoid collisions with existing authfilenumber values:
#   <ead xmlns="urn:isbn:1-931666-22-9"
#        xmlns:arcuit="https://arcuit.library.illinois.edu/ead-extensions">
#     <origination label="Creator">
#       <corpname source="lcnaf"
#                 authfilenumber="n79043912"
#                 arcuit:creator_id="creator_corporate_entities_123">
#         ALA Allied Professional Association
#       </corpname>
#     </origination>
#   </ead>

# Creator ArcLight IDs - extracted from arcuit:creator_id attributes on origination
# name elements (<corpname>, <persname>, <famname>) injected by arcflow.
# Uses custom namespace xmlns:arcuit="https://arcuit.library.illinois.edu/ead-extensions"
# Indexed as an array of creator IDs (e.g., ["creator_corporate_entities_123"])
# for bidirectional creator↔collection linking in Solr.
to_field 'creator_arclight_ids_ssim' do |record, accumulator, context|
  record.xpath('/ead/archdesc/did/origination/persname|
                /ead/archdesc/did/origination/corpname|
                /ead/archdesc/did/origination/famname').each do |node|
    accumulator << node['creator_id']
  end
end

# Record group and sub-group - extracted from recordgroup and subgroup elements
# injected by Arcflow into EAD documents created by ArchivesSpace
to_field 'record_group_ssim', extract_xpath('/ead/archdesc/recordgroup')
to_field 'subgroup_ssim', extract_xpath('/ead/archdesc/subgroup')
