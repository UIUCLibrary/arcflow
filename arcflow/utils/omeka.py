import requests
import json
import os
import yaml

class OmekaClient:
    NOTE_TYPES = {
        'summary': 'dcterms:description',
        'physdesc': 'dcterms:extent',
        'note': 'dcterms:contributor',
        'userestrict': 'dcterms:accessRights'
    }
    AGENT_TYPES = {
        'creator': 'dcterms:creator',
#        'subject': '',
#        'source': ''
    }
    TERM_TYPES = {
        "genre_form": "schema:genre",
        "geographic": "dcterms:spatial",
        "topical": "dcterms:subject",
#        "occupation": "schema:occupation",
#        "uniform_title": "dcterms:alternative"
    }

    def __init__(self, base_url, key_identity, key_credential, logger=None):
        self.log = logger
        self.base_url = base_url
        self.params = {
            'key_identity': key_identity,
            'key_credential': key_credential
        }
        try:
            with open(os.path.join(os.path.abspath((__file__) + "/../"),'enumerations.yml'), 'r') as file:
                self.enumerations  = yaml.safe_load(file)
        except FileNotFoundError:
            self.log.error('File enumerations.yml not found.')
            exit(0)

        if not hasattr(self, 'session'):
            self.session = requests.Session()


    def __del__(self):
        if hasattr(self, 'session'):
            self.session.close()

    def __parse_date(self, date_obj):
        label_value = date_obj.get('label', '')
        begin_date = date_obj.get('begin', '')
        end_date = date_obj.get('end', '')

        if label_value:
            if label_value == 'creation':
                label = ''
            else:
                label = f'{self.enumerations["date_label"].get(label_value, label_value)}: '
        else:
            label = ''

        exp = date_obj.get('expression', '')
        if not exp:
            exp = begin_date if begin_date else ''
            if end_date:
                exp = (exp + ' - ' if exp else '') + end_date

        if date_obj.get('date_type') == 'bulk':
            exp = exp.replace('bulk', '').replace('()', '').strip()
            if begin_date == end_date:
                exp = f'{self.enumerations["bulk"]["_singular"]} {exp}'
            else:
                exp = f'{self.enumerations["bulk"]["_plural"]} {exp}'

        return label, exp, label_value


    def get(self, endpoint, params=None):
        response = self.session.get(
            f'{self.base_url}/{endpoint}', 
            params={**self.params, **(params or {})})
        response.raise_for_status()
        return response.json()


    def __prepare_item_data(self, digital_object):
        """ 
        Prepare the item data to be sent to Omeka.
        Returns a list of tuples for multipart/form-data submission with files
        or a JSON object if no files are present.
        """
        item_data = {
            'dcterms:title': [{
                'property_id': 'auto',
                '@value': digital_object['title'],
                'type': 'literal'
            }],
            'dcterms:identifier': [{
                'property_id': 'auto',
                '@value': digital_object['digital_object_id'],
                'type': 'literal'
            }],
            '@type': 'o:Item',
            'o:is_public': digital_object.get('publish', False),
        }

        if ('repository' in digital_object and 
                '_resolved' in digital_object['repository']):
            item_data['schema:holdingArchive'] = [{
                'property_id': 'auto',
                '@value': digital_object['repository']['_resolved']['name'],
                'type': 'literal',
                'is_public': digital_object['repository']['_resolved'].get('publish', False),
            }]

        if 'collection' in digital_object:
            for collection in digital_object['collection']:
                if '_resolved' in collection:
                    item_data['dcterms:isPartOf'] = item_data.get(
                        'dcterms:isPartOf', [])
                    item_data['dcterms:isPartOf'] = [{
                        'property_id': 'auto',
                        '@value': collection['_resolved']['title'],
                        'type': 'literal',
                        'is_public': collection['_resolved'].get('publish', False),
                    }]

        if 'lang_materials' in digital_object:
            for lang in digital_object['lang_materials']:
                item_data['dcterms:language'] = item_data.get(
                    'dcterms:language', [])
                if 'language_and_script' in lang:
                    language = self.enumerations['language_iso639_2'].get(
                        lang['language_and_script']['language'], lang['language_and_script']['language'])
                    language += f" - {self.enumerations['script_iso15924'].get(lang['language_and_script']['script'], lang['language_and_script']['script'])}" if 'script' in lang['language_and_script'] else ''
                    item_data['dcterms:language'].append({
                        'property_id': 'auto',
                        '@value': language,
                        'type': 'literal',
                    })
                elif 'notes' in lang:
                    for note in lang['notes']:
                        for content in note['content']:
                            item_data['dcterms:language'].append({
                                'property_id': 'auto',
                                '@value': content,
                                'type': 'literal',
                                'is_public': note.get('publish', False),
                            })

        if 'dates' in digital_object:
            for date in digital_object['dates']:
                item_data['dcterms:date'] = item_data.get('dcterms:date', [])
                parsed_date = self.__parse_date(date)
                item_data['dcterms:date'].append({
                    'property_id': 'auto',
                    '@value': f'{parsed_date[0]} {parsed_date[1]}'.strip(),
                    'type': 'literal',
                })

        if 'linked_agents' in digital_object:
            for agent in digital_object['linked_agents']:
                if agent['role'] in self.AGENT_TYPES and '_resolved' in agent:
                    item_data[self.AGENT_TYPES[agent['role']]] = item_data.get(
                        self.AGENT_TYPES[agent['role']], [])
                    item_data[self.AGENT_TYPES[agent['role']]].append({
                        'property_id': 'auto',
                        '@value': agent['_resolved']['title'],
                        'type': 'literal',
                    })

        if 'subjects' in digital_object:
            for subject in digital_object['subjects']:
                if '_resolved' in subject:
                    for term in subject['_resolved']['terms']:
                        if term['term_type'] in self.TERM_TYPES:
                            item_data[self.TERM_TYPES[term['term_type']]] = item_data.get(
                                self.TERM_TYPES[term['term_type']], [])
                            item_data[self.TERM_TYPES[term['term_type']]].append({
                                'property_id': 'auto',
                                '@value': term['term'],
                                'type': 'literal',
                            })

        if 'notes' in digital_object:
            for note in digital_object['notes']:
                if note['type'] in self.NOTE_TYPES:
                    item_data[self.NOTE_TYPES[note['type']]] = item_data.get(
                        self.NOTE_TYPES[note['type']], [])
                    item_data[self.NOTE_TYPES[note['type']]].append({
                        'property_id': 'auto',
                        '@value': "\n\n".join(note['content']),
                        'type': 'literal',
                        'is_public': note.get('publish', False),
                    })

        return item_data


    def create(self, digital_object):
        item_data = self.__prepare_item_data(digital_object)

        form_data = []
        if ('tree' in digital_object and
                '_resolved' in digital_object['tree']):
            i=0
            for child in digital_object['tree']['_resolved']['children']:
                for file_version in child['file_versions']:
#                    if (file_version['file_uri'].startswith('/tmp/')
#                            and os.path.isfile(file_version['file_uri'])):
                    item_data['o:media'] = item_data.get('o:media', [])
                    item_data['o:media'].append({
                        'o:ingester': 'upload',
                        'file_index': i,
                        'o:is_public': child.get('publish', False),
                        'dcterms:title': [{
                            'property_id': 'auto',
                            '@value': child.get('title', ''),
                            'type': 'literal',
                        }],
                    })
                    form_data.append((f'file[{i}]', 
                        open('foellinger-auditorium.jpg', 'rb')))
#                        open(file_version['file_uri'], 'rb')))
                    i += 1

                    # mark as uploaded by removing the /tmp/ prefix
#                    file_version['file_uri'] = file_version['file_uri'].replace('/tmp/','')

        # Only digital objects containing digital object components with files
        # will be created in Omeka (only items with media files)
        if not form_data:
            return None
            # response = self.session.post(
            #     f'{self.base_url}/api/items', params=self.params, json=item_data)
        else:
            form_data.append(('data', (
                None,
                json.dumps(item_data),
                'application/json')))

            response = self.session.post(
                f'{self.base_url}/api/items', params=self.params, files=form_data)

        response.raise_for_status()
        return self.__uv_link(response.json()['o:id'])


    def __uv_link(self, item_id):
        return f'{self.base_url}/item/{item_id}/uv'


    def read(self, digital_object_id):
        return self.get('api/items', params= {
            "property[0][property]": "dcterms:identifier",
            "property[0][type]": "eq",
            "property[0][text]": digital_object_id,
        })


    def upsert(self, digital_object):
        item = self.read(digital_object['digital_object_id'])
        if not item:
            return self.create(digital_object)

        media_list = [media['o:id'] for media in item[0].get('o:media', [])]
        media_sources = self.get('api/media', params={
            'id[]': media_list
        })
        media_list = {media['o:source']: media['o:id'] for media in media_sources}
        primary_media = None

        if ('tree' in digital_object and
                '_resolved' in digital_object['tree']):
            for child in digital_object['tree']['_resolved']['children']:
                for file_version in child['file_versions']:
#                    if (file_version['file_uri'].startswith('/tmp/')
#                            and os.path.isfile(file_version['file_uri'])):
                    if True: #test for already exists in Omeka, just update the metadata
                        media_data = {
                            'o:ingester': 'upload',
                            'file_index': 0,
                            'o:item': {'o:id': item[0]['o:id']},
                            'o:is_public': child.get('publish', False),
                            'dcterms:title': [{
                                'property_id': 'auto',
                                '@value': child.get('title', ''),
                                'type': 'literal',
                            }],
                        }
                        form_data = [
                            (f'file[0]', open(file_version['file_uri'], 'rb')),
                            ('data', (None, json.dumps(media_data), 'application/json')),
                        ]

#                        # mark as uploaded by removing the /tmp/ prefix
#                        file_version['file_uri'] = file_version['file_uri'].replace('/tmp/','')

                        response = self.session.post(
                            f'{self.base_url}/api/media', params=self.params, files=form_data)
                        response.raise_for_status()

                        if file_version['is_representative']:
                            primary_media = response.json()['o:id']

                    # if already exists in Omeka, just update the metadata
                    elif file_version['file_uri'] in media_list:
                        media_data = {
                            'o:is_public': file_version.get('publish', False),
                            'dcterms:title': [{
                                'property_id': 'auto',
                                '@value': child.get('title', ''),
                                'type': 'literal',
                            }],
                            '@type': 'o:Media'
                        }
                        if file_version['is_representative']:
                            primary_media = media_list[file_version['file_uri']]

                        response = self.session.patch(
                            f'{self.base_url}/api/media/{media_list[file_version["file_uri"]]}',
                            params=self.params, json=media_data)
                        response.raise_for_status()

                        media_list.pop(file_version['file_uri'])

        # delete media not present in the digital object anymore
        for media in media_list.values():
            response = self.session.delete(
                f'{self.base_url}/api/media/{media}',
                params=self.params)
            response.raise_for_status()

        # update the item metadata
        item_data = self.__prepare_item_data(digital_object)
        if primary_media:
            item_data['o:primary_media'] = {
                'o:id': primary_media
            }
        response = self.session.patch(
            f'{self.base_url}/api/items/{item[0]["o:id"]}',
            params=self.params, json=item_data)
        response.raise_for_status()
        return self.__uv_link(response.json()['o:id'])


    def delete(self, digital_object_id):
        item = self.read(digital_object_id)
        if not item:
            return None

        response = self.session.delete(
            f'{self.base_url}/api/items/{item[0]["o:id"]}',
            params=self.params)
        response.raise_for_status()
        return response.status_code == 204