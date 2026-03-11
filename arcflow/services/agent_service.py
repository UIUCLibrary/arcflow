"""
Service for fetching and processing agent data from ArchivesSpace.

Handles agent-related operations including:
- Fetching agent biographical/historical notes
- Processing note content into structured data
"""

import logging
from typing import Optional, List, Dict


class AgentService:
    """Service for agent data fetching and processing."""

    def __init__(self, client, log=None):
        """
        Initialize the agent service.

        Args:
            client: ASnake client for fetching agent data
            log: Logger instance (optional, creates default if not provided)
        """
        self.client = client
        self.log = log or logging.getLogger(__name__)

    def get_agent_bioghist_data(self, agent_uri: str, indent_size: int = 0) -> Optional[Dict]:
        """
        Fetch bioghist DATA for an agent.

        Returns structured data (not XML) so it can be used in different contexts:
        - Build EAD XML for collections
        - Build EAC-CPF XML for creator records
        - Display in a web UI
        - Export as JSON

        Args:
            agent_uri: Agent URI from ArchivesSpace (e.g., '/agents/corporate_entities/123')
            indent_size: Indentation size for logging

        Returns:
            dict with keys: 'agent_name', 'persistent_id', 'paragraphs'
            or None if no bioghist found or on error
        """
        indent = ' ' * indent_size

        try:
            agent = self.client.get(agent_uri).json()
            agent_name = agent.get('title') or agent.get('display_name', {}).get('sort_name', 'Unknown')

            for note in agent.get('notes', []):
                if note.get('jsonmodel_type') == 'note_bioghist':
                    persistent_id = note.get('persistent_id')
                    paragraphs = self._extract_paragraphs(note, agent_uri, indent_size)

                    if paragraphs:
                        return {
                            'agent_name': agent_name,
                            'persistent_id': persistent_id,
                            'paragraphs': paragraphs
                        }

            return None  # No bioghist

        except Exception as e:
            self.log.error(f'{indent}Error fetching agent {agent_uri}: {e}')
            return None

    def _extract_paragraphs(self, note: dict, agent_uri: str, indent_size: int = 0) -> List[str]:
        """
        Extract paragraph content from a bioghist note.

        Args:
            note: Note dictionary from ArchivesSpace
            agent_uri: Agent URI for logging purposes
            indent_size: Indentation size for logging

        Returns:
            List of plain text paragraph strings (not wrapped in <p> tags)
        """
        indent = ' ' * indent_size
        paragraphs = []

        if 'subnotes' in note:
            for subnote in note['subnotes']:
                if 'content' in subnote:
                    content = subnote['content']

                    # Handle content as either string or list with explicit type checking
                    if isinstance(content, str):
                        # Split on newline and filter out empty strings
                        lines = [line.strip() for line in content.split('\n') if line.strip()]
                    elif isinstance(content, list):
                        # Content is already a list - use as is
                        lines = [str(item).strip() for item in content if str(item).strip()]
                    else:
                        # Log unexpected content type prominently
                        self.log.error(
                            f'{indent}**ASSUMPTION VIOLATION**: Expected string or list for subnote content '
                            f'in agent {agent_uri}, got {type(content).__name__}'
                        )
                        continue

                    # Add plain text lines (will be wrapped in <p> tags by build_bioghist_element)
                    for line in lines:
                        paragraphs.append(line)

        # Log if persistent_id is missing
        if not note.get('persistent_id'):
            self.log.error(
                f'{indent}**ASSUMPTION VIOLATION**: Expected persistent_id in note_bioghist '
                f'for agent {agent_uri}'
            )

        return paragraphs
