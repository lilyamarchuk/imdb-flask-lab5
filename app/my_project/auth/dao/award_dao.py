from my_project.auth.dao.base_dao import BaseDAO
from my_project.auth.domain import Award


class AwardDAO(BaseDAO):
    model = Award

    def find_by_movie(self, movie_id):
        return Award.query.filter_by(movie_id=movie_id).order_by(Award.award_year, Award.award_id).all()
