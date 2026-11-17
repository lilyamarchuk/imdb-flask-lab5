from my_project.auth.controller.base_controller import BaseController
from my_project.auth.service.movie_delete_log_service import MovieDeleteLogService


class MovieDeleteLogController(BaseController):
    def __init__(self):
        super().__init__(MovieDeleteLogService())
