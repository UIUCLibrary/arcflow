"""
Read ArchivesSpace digital object metadata the same way for every export.

OmekaService (Omeka items) and DigitalObjectModsService (MODS sidecars for
Arcuit) map digital objects to different schemas, but they should agree on
how a digital object's fields are read: which name to show for an agent,
how dates are labelled, which subjects are resolved and what a note says.
"""

import os

import yaml


ENUMERATIONS_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), 'omeka', 'enumerations.yml')


def load_enumerations(path=ENUMERATIONS_PATH):
    """
    Load the display values of ArchivesSpace enumerations (date labels,
    bulk date prefixes, language and script names).

    Raises:
        FileNotFoundError: if the enumerations file is missing
    """
    with open(path, 'r') as file:
        return yaml.safe_load(file) or {}


def date_label(date, enumerations):
    """Display label of a date, or '' for creation dates."""
    label = date.get('label') or 'creation'
    if label == 'creation':
        return ''
    return enumerations.get('date_label', {}).get(label, label)


def bulk_date_expression(date, expression, enumerations):
    """Prefix a bulk date's expression, e.g. 'Majority of material found in 1930'."""
    if date.get('date_type') != 'bulk':
        return expression
    expression = expression.replace('bulk', '').replace('()', '').strip()
    single = (date.get('begin') or '') == (date.get('end') or '')
    prefix = enumerations.get('bulk', {}).get('_singular' if single else '_plural')
    return f'{prefix} {expression}' if prefix else expression


def agent_name(agent):
    """Display name of a resolved agent."""
    return agent.get('title') or agent.get('display_name', {}).get('sort_name')


def resolved_subjects(digital_object):
    """The digital object's subjects that were resolved."""
    return [s['_resolved'] for s in digital_object.get('subjects', []) if s.get('_resolved')]


def note_paragraphs(note):
    """Paragraphs of a note's content (and bibliography items), with their markup."""
    content = note.get('content', [])
    if isinstance(content, str):
        content = [content]
    return list(content) + list(note.get('items', []))
