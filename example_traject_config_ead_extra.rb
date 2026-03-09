# Example Traject extra config for EAD collection indexing
#
# This file shows the fields that arcflow injects into EAD XML to support
# bidirectional creator↔collection linking in Solr. Add this content to
# your arcuit installation's ead_extra_config.rb file:
#   {arclight_dir}/lib/arcuit/traject/ead_extra_config.rb
#
# Arcflow adds authfilenumber attributes to origination name elements:
#   <origination label="Creator">
#     <corpname source="lcnaf" authfilenumber="creator_corporate_entities_123">
#       ALA Allied Professional Association
#     </corpname>
#   </origination>
#
# Usage (called automatically by arcflow, or manually):
#   bundle exec traject -u $SOLR_URL -i xml \
#     -c {arclight_dir}/lib/arclight/traject/ead2_config.rb \
#     -c {arclight_dir}/lib/arcuit/traject/ead_extra_config.rb \
#     /path/to/xml/*.xml

# Creator ArcLight IDs - extracted from authfilenumber attributes on origination
# name elements (<corpname>, <persname>, <famname>) injected by arcflow.
# Indexed as an array of creator IDs (e.g., ["creator_corporate_entities_123"])
# for bidirectional creator↔collection linking in Solr.
to_field 'creator_arclight_ids_ssim' do |record, accumulator|
  record.xpath('//ead:archdesc/ead:did/ead:origination/ead:corpname[@authfilenumber] |
                //ead:archdesc/ead:did/ead:origination/ead:persname[@authfilenumber] |
                //ead:archdesc/ead:did/ead:origination/ead:famname[@authfilenumber]',
               'ead' => 'urn:isbn:1-931666-22-9').each do |node|
    accumulator << node['authfilenumber']
  end
  # Also check without namespace (some ASpace EAD exports omit it)
  if accumulator.empty?
    record.xpath('//archdesc/did/origination/corpname[@authfilenumber] |
                  //archdesc/did/origination/persname[@authfilenumber] |
                  //archdesc/did/origination/famname[@authfilenumber]').each do |node|
      accumulator << node['authfilenumber']
    end
  end
end
