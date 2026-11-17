from my_project.auth.dao.movie_delete_log_dao import MovieDeleteLogDAO
from my_project.auth.service.base_service import BaseService


class MovieDeleteLogService(BaseService):
    dao = MovieDeleteLogDAO()
    label = "Запис журналу"
