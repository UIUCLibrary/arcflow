import requests
import json
import os
import yaml
import mssql_python
import uuid
from io import BytesIO, BufferedReader
from utils.stage_classifications import labels_from_path


class OmekaClient:
    NOTE_TYPES = {
        'summary': 'dcterms:description',
        'physdesc': 'dcterms:extent',
        'note': {
            'contributornote': 'dcterms:contributor',
            'contributor': 'dcterms:contributor',
        },
        'userestrict': 'dcterms:accessRights'
    }
    AGENT_TYPES = {
        'creator': 'dcterms:creator',
        'subject': 'dcterms:subject',
#        'source': ''
    }
    TERM_TYPES = {
        'genre_form': 'schema:genre',
        'geographic': 'dcterms:spatial',
        'topical': 'dcterms:subject',
#        'occupation': 'schema:occupation',
#        'uniform_title': 'dcterms:alternative'
    }


    def __init__(self, *args, **kwargs):
        self.log = kwargs.get('logger', None)
        self.asnake_client = kwargs.get('asnake_client', None)
        self.dry_run_aspace = kwargs.get('dry_run_aspace', False)
        self.tmp_dir = kwargs.get('tmp_dir', '/tmp/')
        self.base_url = kwargs['omeka']['baseurl']
        self.params = {
            'key_identity': kwargs['omeka']['key_identity'],
            'key_credential': kwargs['omeka']['key_credential'],
        }
        self.use_archon = kwargs.get('use_archon', 0)
        if self.use_archon:
            self.archon = kwargs.get('archon', {})
            # separate multiple repo IDs mapped to the same Archon connection
            tmp = {}
            for repo_ids, conn in self.archon.items():
                for repo_id in repo_ids.split(','):
                    tmp[repo_id] = conn
            self.archon = tmp

        try:
            with open(os.path.join(os.path.abspath((__file__) + "/../"), 'enumerations.yml'), 'r') as file:
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


    def __is_public(self, obj):
        if 'suppressed' in obj and obj['suppressed']:
            return False

        return obj.get('publish', False)


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
            'dcterms:identifier': [
                # Store the digital object URI as the primary identifier 
                # for the item in Omeka. This allows Omeka to uniquely identify 
                # the item and verify if it already exists.
                {
                    'property_id': 'auto',
                    '@value': digital_object['uri'],
                    'type': 'literal',
                    'is_public': False,
                },
                {
                    'property_id': 'auto',
                    '@value': digital_object['digital_object_id'],
                    'type': 'literal'
                },
            ],
            '@type': 'o:Item',
            'o:is_public': self.__is_public(digital_object),
        }

        if ('repository' in digital_object and 
                '_resolved' in digital_object['repository']):
            item_data['schema:holdingArchive'] = [{
                'property_id': 'auto',
                '@value': digital_object['repository']['_resolved']['name'],
                'type': 'literal',
                'is_public': self.__is_public(digital_object['repository']['_resolved']),
            }]

        if 'collection' in digital_object:
            for collection in digital_object['collection']:
                if '_resolved' in collection:
                    if 'classifications' in collection['_resolved']:
                        for classification in collection['_resolved']['classifications']:
                            classification_terms = self.asnake_client.get(
                                classification['ref']
                            ).json()
                            group_labels = labels_from_path(classification_terms['path_from_root'])
                            for group_label in group_labels:
                                item_data['dcterms:isPartOf'] = item_data.get(
                                    'dcterms:isPartOf', [])
                                item_data['dcterms:isPartOf'].append({
                                    'property_id': 'auto',
                                    '@value': group_label,
                                    'type': 'literal',
                                    'is_public': self.__is_public(classification_terms),
                                })
                    item_data['dcterms:isPartOf'] = item_data.get(
                        'dcterms:isPartOf', [])
                    item_data['dcterms:isPartOf'].append({
                        'property_id': 'auto',
                        '@value': f'{collection["_resolved"]["ead_id"]} — {collection["_resolved"]["title"]}',
                        'type': 'literal',
                        'is_public': self.__is_public(collection['_resolved']),
                    })

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
                                'is_public': self.__is_public(note),
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
                if note['type'] == 'note':
                    note_label = note['label'].lower().strip().replace(' ', '')
                    if note_label in self.NOTE_TYPES['note']:
                        item_data[self.NOTE_TYPES['note'][note_label]] = item_data.get(
                            self.NOTE_TYPES['note'][note_label], [])
                        item_data[self.NOTE_TYPES['note'][note_label]].append({
                            'property_id': 'auto',
                            '@value': "\n\n".join(note['content']),
                            'type': 'literal',
                            'is_public': self.__is_public(note),
                        })
                elif note['type'] in self.NOTE_TYPES:
                    item_data[self.NOTE_TYPES[note['type']]] = item_data.get(
                        self.NOTE_TYPES[note['type']], [])
                    item_data[self.NOTE_TYPES[note['type']]].append({
                        'property_id': 'auto',
                        '@value': "\n\n".join(note['content']),
                        'type': 'literal',
                        'is_public': self.__is_public(note),
                    })

        return item_data


    def __get_file_from_archon(self, file_name, repo_id, indent_size=0):
        """
            Retrieves a file from the Archon database based on the file name and repository ID.
            Returns a tuple of (DefaultAccessLevel, FileContents, FilePreviewLong, FilePreviewShort) if the file is found,
            or (None, None, None, None) if the file is not found.
        """
        indent = ' ' * indent_size

        connection_str = f"Server=tcp:{self.archon[repo_id]['host']},{self.archon[repo_id]['port']};Database={self.archon[repo_id]['database']};Encrypt=yes;TrustServerCertificate=no;Authentication=SqlPassword;UID={self.archon[repo_id]['username']};PWD={self.archon[repo_id]['password']};"
        with mssql_python.connect(connection_str) as connection:
            cursor = connection.cursor()
            cursor.execute("SELECT DefaultAccessLevel, FileContents, FilePreviewLong, FilePreviewShort FROM tblDigitalLibrary_Files WHERE Filename = ?;", (file_name,))
            row = cursor.fetchone()
            if row:
                self.log.info(f'{indent}Importing file "{file_name}" from Archon database {self.archon[repo_id]["database"]}.')

                return row[0], BytesIO(row[1]), BytesIO(row[2]), BytesIO(row[3])

            return None, None, None, None


    def __prepare_media_data(self, **kwargs):
        media_data =  {
            'o:is_public': kwargs.get('is_public', False),
            'dcterms:title': [{
                'property_id': 'auto',
                '@value': kwargs.get('title', ''),
                'type': 'literal',
            }],
            'dcterms:alternative': [{
                'property_id': 'auto',
                '@value': kwargs.get('label', ''),
                'type': 'literal',
            }],
            'schema:caption': [{
                'property_id': 'auto',
                '@value': kwargs.get('caption', ''),
                'type': 'literal',
            }],
        }

        if 'file_index' in kwargs:
            media_data['o:ingester'] = 'upload'
            media_data['file_index'] = kwargs['file_index']

        if 'item_type' in kwargs:
            media_data['@type'] = kwargs['item_type']

        if 'item_id' in kwargs:
            media_data['o:item'] = {'o:id': kwargs['item_id']}

        return media_data


    def create(self, digital_object, indent_size=0):
        indent = ' ' * indent_size
        item_data = self.__prepare_item_data(digital_object)
        form_data = []
        if ('tree' in digital_object and
                '_resolved' in digital_object['tree']):
            i=0
            for child in digital_object['tree']['_resolved']['children']:
                # resolved does not include label, so we need to get the 
                # digital object component record for each child to get those values
                digital_object_component = self.asnake_client.get(
                    child['record_uri']
                ).json()
                title = digital_object_component.get('title', '')
                label = digital_object_component.get('label', '')
                is_public = self.__is_public(digital_object_component)
                for file_version in child['file_versions']:
                    if ('file_format_version' in file_version):
                        file_name = f'{file_version["file_format_version"]}_{file_version["file_uri"]}'
                        file_path = f'{self.tmp_dir}{file_name}'

                        if(os.path.isfile(file_path)):
                            item_data['o:media'] = item_data.get('o:media', [])
                            item_data['o:media'].append(self.__prepare_media_data(
                                file_index=i,
                                is_public=self.__is_public(file_version) if is_public else False,
                                title=title,
                                label=label,
                                caption=file_version.get('caption', '')))
                            form_data.append((f'file[{i}]', 
                                (file_name, open(file_path, 'rb'))))

                            i += 1
                    elif self.use_archon:
                        access_level, file_obj, file_long, file_short = self.__get_file_from_archon(title, 
                            digital_object['repository']['ref'].split('/')[-1], indent_size)

                        file_access_level = True if access_level > 1 else False
                        if file_obj:
                            item_data['o:media'] = item_data.get('o:media', [])
                            item_data['o:media'].append(self.__prepare_media_data(
                                file_index=i,
                                is_public=file_access_level if is_public else False,
                                title=title,
                                label=label))

                            file_version['file_format_version'] = str(uuid.uuid4())
                            file_version['publish'] = file_access_level
                            file_name = f'{file_version["file_format_version"]}_{file_version["file_uri"]}'

                            form_data.append((f'file[{i}]', (file_name, file_obj)))

                            caption = ''
                            previews = [(file_long, 'Long Preview'), (file_short, 'Short Preview')]
                            if access_level == 0:
                                try:
                                    file_unavailable = open(os.path.join(os.path.abspath((__file__) + "/../"), 'no_preview_available.png'), 'rb')
                                    previews.append((file_unavailable, 'No Preview'))
                                except FileNotFoundError:
                                    self.log.error('File no_preview_available.png not found.')
                                    exit(0)

                                caption = 'No preview for this item is publicly available. Contact the archives for information about accessing this item.'
                                file_access_level = False
                            elif access_level == 1:
                                caption = 'Download of the full file is not publicly available. Contact the archives for information about accessing this item.'
                                file_access_level = True
                            for file_preview, preview_type in previews:
                                i += 1
                                file_name = file_version["file_uri"].split('.')
                                file_name = f'{file_name[0]}_{preview_type.lower().replace(" ", "_")}.{file_name[-1]}'
                                item_data['o:media'].append(self.__prepare_media_data(
                                    file_index=i,
                                    is_public=True if preview_type == 'No Preview'  else file_access_level,
                                    title=f'{title} ({preview_type})',
                                    label=f'{label} ({preview_type})',
                                    caption=caption))
                                form_data.append((f'file[{i}]',
                                    (f'{file_version["file_format_version"]}_{file_name}',
                                    file_preview)))

                                child['file_versions'].append({
                                    'file_uri': file_name,
                                    'file_format_version': file_version["file_format_version"],
                                    'caption': caption,
                                    'publish': file_access_level,
                                    'jsonmodel_type': 'file_version',
                                })

                            if not self.dry_run_aspace:
                                # update digital object component with new file_format_version
                                digital_object_component['file_versions'] = child['file_versions']
                                updated = self.asnake_client.post(
                                    digital_object_component['uri'],
                                    json={
                                        **digital_object_component,
                                    }
                                ).json()
                            if 'id' in child:
                                self.log.info(f'{indent}Updated digital object component ID {child["id"]} "{title}", file_version ID {file_version["id"]}, file_format_version: {file_version["file_format_version"]}')

                            i += 1

        # Only digital objects containing digital object components with files
        # will be created in Omeka (only items with media files)
        if not form_data:
            # return None

            for file_version in digital_object['file_versions']:
                item_data['schema:url'] = item_data.get('schema:url', [])
                item_data['schema:url'].append({
                    'property_id': 'auto',
                    '@id': file_version['file_uri'],
                    'type': 'uri',
                    'is_public': self.__is_public(file_version),
                })

            try:
                file_unavailable = open(os.path.join(os.path.abspath((__file__) + "/../"), 'no_preview_available.png'), 'rb')
            except FileNotFoundError:
                self.log.error('File placeholder.png not found.')
                exit(0)
            item_data['o:media'] = [self.__prepare_media_data(
                file_index=0,
                is_public=True,)]
            form_data.append((f'file[0]',
                ('no_preview_available.png', file_unavailable)))

        #     response = self.session.post(
        #         f'{self.base_url}/api/items', params=self.params, json=item_data)
        # else:
        form_data.append(('data', (
            None,
            json.dumps(item_data),
            'application/json')))
        response = self.session.post(
            f'{self.base_url}/api/items', params=self.params, files=form_data)

        try:
            file_unavailable.close()
        except:
            pass

        response.raise_for_status()
        return self.__update_omeka_uri(digital_object, response.json()['o:id'])


    def __update_omeka_uri(self, digital_object, omeka_id):
        omeka_uri = f'{self.base_url}/item/{omeka_id}/uv'
        has_omeka_uri = False

        for file_version in digital_object['file_versions']:
            if file_version['file_uri'] == omeka_uri:
                has_omeka_uri = True
                break

        if not self.dry_run_aspace and not has_omeka_uri and omeka_uri:
            digital_object['file_versions'].append({
                'file_uri': omeka_uri,
                'publish': self.__is_public(digital_object),
                'is_representative': True,
                'jsonmodel_type': 'file_version',
            })

            updated_object = self.asnake_client.post(
                digital_object['uri'],
                json={
                    **digital_object
                }).json()

        return omeka_uri


    def read(self, digital_object_uri):
        return self.get('api/items', params= {
            "property[0][property]": "dcterms:identifier",
            "property[0][type]": "eq",
            "property[0][text]": digital_object_uri,
        })


    def upsert(self, digital_object, soft_delete=True, indent_size=0):
        indent = ' ' * indent_size

        item = self.read(digital_object['uri'])
        if not item:
            return self.create(digital_object, indent_size)

        media_list = [media['o:id'] for media in item[0].get('o:media', [])]
        media_sources = self.get('api/media', params={
            'id[]': media_list
        })
        media_list = {media['o:source']: media['o:id'] for media in media_sources}
        primary_media = None

        has_children = False
        if ('tree' in digital_object and
                '_resolved' in digital_object['tree']):
            for child in digital_object['tree']['_resolved']['children']:
                # resolved does not include label, so we need to get the 
                # digital object component record for each child to get those values
                digital_object_component = self.asnake_client.get(
                    child['record_uri']
                ).json()
                title = digital_object_component.get('title', '')
                label = digital_object_component.get('label', '')
                is_public = self.__is_public(digital_object_component)
                for file_version in child['file_versions']:
                    if ('file_format_version' in file_version):
                        file_name = f'{file_version["file_format_version"]}_{file_version["file_uri"]}'
                        file_path = f'{self.tmp_dir}{file_name}'
                        caption = file_version.get('caption', '')

                        # if already exists in Omeka, just update the metadata
                        if (file_name in media_list):
                            media_data = self.__prepare_media_data(
                                is_public=self.__is_public(file_version) if is_public else False,
                                title=title,
                                label=label,
                                caption=caption,
                                item_type='o:Media')
                            if file_version['is_representative']:
                                primary_media = media_list[file_name]
                            response = self.session.patch(
                                f'{self.base_url}/api/media/{media_list[file_name]}',
                                params=self.params, json=media_data)
                            response.raise_for_status()

                            media_list.pop(file_name)

                        # if not, create a new media
                        elif (os.path.isfile(file_path)):
                            media_data = self.__prepare_media_data(
                                file_index=0,
                                item_id=item[0]['o:id'],
                                is_public=self.__is_public(file_version) if is_public else False,
                                title=title,
                                label=label,
                                caption=caption)
                            form_data = [
                                (f'file[0]', (file_name, open(file_path, 'rb'))),
                                ('data', (None, json.dumps(media_data), 'application/json')),
                            ]

                            response = self.session.post(
                                f'{self.base_url}/api/media', params=self.params, files=form_data)
                            response.raise_for_status()

                            if file_version['is_representative']:
                                primary_media = response.json()['o:id']

                            if not has_children:
                                has_children = True

        # delete media not present in the digital object anymore
        if soft_delete and has_children:
            for media in media_list.values():
                response = self.session.patch(
                    f'{self.base_url}/api/media/{media}',
                    params=self.params, json={
                        'o:is_public': False,
                    })
                response.raise_for_status()
        # uncomment the following lines for hard delete in Omeka 
        # (delete media files permanently, so use with caution)
        # else:
        #     for media in media_list.values():
        #         response = self.session.delete(
        #             f'{self.base_url}/api/media/{media}',
        #             params=self.params)
        #         response.raise_for_status()

        # update the item metadata
        item_data = self.__prepare_item_data(digital_object)
        if primary_media:
            item_data['o:primary_media'] = {
                'o:id': primary_media
            }

        if not has_children:
            omeka_uri = f'{self.base_url}/item/{item[0]["o:id"]}/uv'
            for file_version in digital_object['file_versions']:
                if file_version['file_uri'] != omeka_uri:
                    item_data['schema:url'] = item_data.get('schema:url', [])
                    item_data['schema:url'].append({
                        'property_id': 'auto',
                        '@id': file_version['file_uri'],
                        'type': 'uri',
                        'is_public': self.__is_public(file_version),
                    })
                    break

        response = self.session.patch(
            f'{self.base_url}/api/items/{item[0]["o:id"]}',
            params=self.params, json=item_data)
        response.raise_for_status()
        return self.__update_omeka_uri(digital_object, response.json()['o:id'])


    def delete(self, digital_object_uri, soft_delete=True):
        item = self.read(digital_object_uri)
        if not item:
            return None

        if soft_delete:
            response = self.session.patch(
                f'{self.base_url}/api/items/{item[0]["o:id"]}',
                params=self.params, json={
                    'o:is_public': False,
                })
            response.raise_for_status()
            return response.status_code == 200
        # uncomment the following lines for hard delete in Omeka 
        # (deletes the item and all its media files permanently, so use with caution)
        # else:
        #     response = self.session.delete(
        #         f'{self.base_url}/api/items/{item[0]["o:id"]}',
        #         params=self.params)

        #     response.raise_for_status()
        #     return response.status_code == 204


    def delete_all(self, soft_delete=True, indent_size=0):
        indent = ' ' * indent_size

        if soft_delete:
            page = 1
            while True:
                items = self.get('api/items',
                    params={
                        'page': page,
                    })
                if not items:
                    break

                for item in items:
                    response = self.session.patch(
                        f'{self.base_url}/api/items/{item["o:id"]}',
                        params=self.params, json={
                            'o:is_public': False,
                        })
                    response.raise_for_status()
                self.log.info(f'{indent}Soft deleted batch of {len(items)} items found.')

                page += 1
        # uncomment the following lines for hard delete in Omeka 
        # (deletes all items and their media files permanently, so use with caution)
        # else:
        #     while True:
        #         items = self.get('api/items')
        #         if not items:
        #             break

        #         for item in items:
        #             response = self.session.delete(
        #                 f'{self.base_url}/api/items/{item["o:id"]}',
        #                 params=self.params)
        #             response.raise_for_status()
        #         self.log.info(f'{indent}Deleted batch of {len(items)} items found.')

