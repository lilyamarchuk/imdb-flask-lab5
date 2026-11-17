from my_project.auth.dao.award_dao import AwardDAO
from my_project.auth.service.base_service import BaseService
from my_project.utils.errors import ApiError


class AwardService(BaseService):
    dao = AwardDAO()
    label = "Нагорода"
    required = ("movie_id", "award_name", "award_year")

    def validate(self, data):
        if "award_year" in data:
            year = data["award_year"]
            if not isinstance(year, int) or not 1900 <= year <= 2100:
                raise ApiError("award_year має бути цілим числом від 1900 до 2100", 400)
        if "movie_id" in data and not isinstance(data["movie_id"], int):
            raise ApiError("movie_id має бути цілим числом", 400)
