import requests
import logging
from datetime import datetime, timezone
from typing import List, Dict, Optional


class SolrService:
    """
    Handles all Solr operations including querying, filtering, and record deletion.
    Supports both ArcLight Solr and ArchivesSpace Solr instances.
    """

    def __init__(self, solr_url: str, aspace_solr_url: str, logger: logging.Logger, force_update: bool = False):
        """
        Initialize the Solr service.

        Args:
            solr_url: URL of the ArcLight Solr core
            aspace_solr_url: URL of the ArchivesSpace Solr core
            logger: Logger instance for logging operations
            force_update: If True, ignore modified_since timestamps in queries
        """
        self.solr_url = solr_url
        self.aspace_solr_url = aspace_solr_url
        self.log = logger
        self.force_update = force_update

    def get_target_agent_criteria(self, modified_since: int = 0) -> List[str]:
        """
        Defines the Solr query criteria for "target" agents.
        These are agents we want to process.

        Args:
            modified_since: Unix timestamp to filter by modification time

        Returns:
            List of query criteria strings
        """
        criteria = [
            "linked_agent_roles:creator",
            "system_generated:false",
            "is_user:false",
#             "is_repo_agent:false",
        ]

        # Add time filter if applicable
        if modified_since > 0 and not self.force_update:
            mtime_utc = datetime.fromtimestamp(modified_since, tz=timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
            criteria.append(f"system_mtime:[{mtime_utc} TO *]")

        return criteria

    def get_nontarget_agent_criteria(self, modified_since: int = 0) -> List[str]:
        """
        Defines the Solr query criteria for "non-target" (excluded) agents.
        This is the logical inverse of the target criteria.

        Args:
            modified_since: Unix timestamp to filter by modification time

        Returns:
            List of query criteria strings
        """
        # The core logic for what makes an agent a "target"
        target_logic = " AND ".join([
            "linked_agent_roles:creator",
            "system_generated:false",
            "is_user:false",
#             "is_repo_agent:false",
        ])

        # We find non-targets by negating the entire block of target logic
        criteria = [f"NOT ({target_logic})"]

        # We still apply the time filter to the overall query
        if modified_since > 0 and not self.force_update:
            mtime_utc = datetime.fromtimestamp(modified_since, tz=timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
            criteria.append(f"system_mtime:[{mtime_utc} TO *]")

        return criteria

    def execute_query(self, query_parts: List[str], solr_url: Optional[str] = None,
                      fields: List[str] = None, indent_size: int = 0) -> List[Dict]:
        """
        A generic function to execute a query against the Solr index.

        Args:
            query_parts: A list of strings that will be joined with " AND "
            solr_url: Solr URL to use (defaults to self.solr_url if not provided)
            fields: List of Solr fields to return in the response
            indent_size: Indentation size for logging

        Returns:
            List of dictionaries, where each dictionary contains the requested fields.
            Returns an empty list on failure.
        """
        if fields is None:
            fields = ['id']

        indent = ' ' * indent_size
        if not query_parts:
            self.log.error("Cannot execute Solr query with empty criteria.")
            return []

        if not solr_url:
            solr_url = self.solr_url

        query_string = " AND ".join(query_parts)
        self.log.info(f"{indent}Executing Solr query: {query_string}")

        try:
            # First, get the total count of matching documents
            count_params = {'q': query_string, 'rows': 0, 'wt': 'json'}
            count_response = requests.get(f'{solr_url}/select', params=count_params)
            self.log.info(f"  [Solr Count Request]: {count_response.request.url}")

            count_response.raise_for_status()
            num_found = count_response.json()['response']['numFound']

            if num_found == 0:
                return []  # No need to query again if nothing was found

            # Now, fetch the actual data for the documents
            data_params = {
                'q': query_string,
                'rows': num_found,  # Use the exact count to fetch all results
                'fl': ','.join(fields),  # Join field list into a comma-separated string
                'wt': 'json'
            }
            response = requests.get(f'{solr_url}/select', params=data_params)
            response.raise_for_status()
            # Log the exact URL for the data request
            self.log.info(f"  [Solr Data Request]: {response.request.url}")

            return response.json()['response']['docs']

        except requests.exceptions.RequestException as e:
            self.log.error(f"Failed to execute Solr query: {e}")
            self.log.error(f"  Failed query string: {query_string}")
            return []

    def get_all_agents(self, agent_types: Optional[List[str]] = None,
                       modified_since: int = 0, indent_size: int = 0) -> List[str]:
        """
        Fetch target agent URIs from the Solr index and log non-target agents.

        Args:
            agent_types: List of agent types to query (defaults to person, corporate_entity, family)
            modified_since: Unix timestamp to filter by modification time
            indent_size: Indentation size for logging

        Returns:
            List of agent URIs for target agents
        """
        if agent_types is None:
            agent_types = ['agent_person', 'agent_corporate_entity', 'agent_family']

        if self.force_update:
            modified_since = 0
        indent = ' ' * indent_size
        self.log.info(f'{indent}Fetching agent data from Solr...')

        # Base criteria for all queries in this function
        base_criteria = [f"primary_type:({' OR '.join(agent_types)})"]

        # Get and log the non-target agents
        nontarget_criteria = base_criteria + self.get_nontarget_agent_criteria(modified_since)
        excluded_docs = self.execute_query(nontarget_criteria, self.aspace_solr_url, fields=['id'])
        if excluded_docs:
            excluded_ids = [doc['id'] for doc in excluded_docs]
            self.log.info(f"{indent}  Found {len(excluded_ids)} non-target (excluded) agents.")
            # Optional: Log the actual IDs if the list isn't too long
            # for agent_id in excluded_ids:
            #     self.log.debug(f"{indent}    - Excluded: {agent_id}")

        # Get and return the target agents
        target_criteria = base_criteria + self.get_target_agent_criteria(modified_since)
        self.log.info('Target Criteria:')
        target_docs = self.execute_query(target_criteria, self.aspace_solr_url, fields=['id'])

        target_agents = [doc['id'] for doc in target_docs]
        self.log.info(f"{indent}  Found {len(target_agents)} target agents to process.")

        return target_agents

    def delete_record(self, solr_record_id: str, indent_size: int = 0) -> bool:
        """
        Delete a record from ArcLight Solr by ID.

        Args:
            solr_record_id: The Solr document ID to delete
            indent_size: Indentation size for logging

        Returns:
            True if deletion was successful, False otherwise
        """
        indent = ' ' * indent_size

        try:
            response = requests.post(
                f'{self.solr_url}/update?commit=true',
                json={'delete': {'id': solr_record_id}},
            )
            if response.status_code == 200:
                self.log.info(f'{indent}Deleted Solr record {solr_record_id} from ArcLight Solr')
                return True
            else:
                self.log.error(
                    f'{indent}Failed to delete Solr record {solr_record_id} from ArcLight Solr. Status code: {response.status_code}')
                return False
        except requests.exceptions.RequestException as e:
            self.log.error(f'{indent}Error deleting Solr record {solr_record_id} from ArcLight Solr: {e}')
            return False
