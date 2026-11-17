from my_project.auth.dao.base_dao import BaseDAO
from my_project.auth.domain import MovieDeleteLog


class MovieDeleteLogDAO(BaseDAO):
    model = MovieDeleteLog

    def find_all(self):
        return MovieDeleteLog.query.order_by(MovieDeleteLog.log_id.desc()).all()
