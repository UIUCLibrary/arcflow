"""
ArcFlow package for syncing ArchivesSpace to ArcLight.

To use ArcFlow, import directly from the main module:
    from arcflow.main import ArcFlow

Services can be imported independently:
    from arcflow.services.xml_transform_service import XmlTransformService
    from arcflow.services.agent_service import AgentService

The top-level import is disabled to avoid eager loading of dependencies.
"""

# Avoid eager imports to allow services to be imported independently
# from .main import ArcFlow