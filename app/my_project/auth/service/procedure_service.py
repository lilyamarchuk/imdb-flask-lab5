from my_project.auth.dao.procedure_dao import ProcedureDAO
from my_project.auth.service.helpers import parse_date
from my_project.utils.errors import ApiError


def _require(data, fields):
    if not isinstance(data, dict):
        raise ApiError("Тіло запиту має бути JSON-об'єктом", 400)
    missing = [f for f in fields if data.get(f) in (None, "")]
    if missing:
        raise ApiError(f"Відсутні обов'язкові поля: {', '.join(missing)}", 400)


class ProcedureService:
    dao = ProcedureDAO()

    def insert_person(self, data):
        _require(data, ("full_name",))
        birth_date = parse_date(data["birth_date"], "birth_date") if data.get("birth_date") else None
        return self.dao.insert_person(data["full_name"], birth_date,
                                      data.get("birth_place"), data.get("biography"))[0]

    def add_movie_genre(self, data):
        _require(data, ("movie_title", "genre_name"))
        return self.dao.add_movie_genre(data["movie_title"], data["genre_name"])[0]

    def add_movie_country(self, data):
        _require(data, ("movie_title", "country_name"))
        return self.dao.add_movie_country(data["movie_title"], data["country_name"])[0]

    def insert_noname_genres(self):
        return self.dao.insert_noname_genres()

    def delete_noname_genres(self):
        return self.dao.delete_noname_genres()[0]

    def rating_stat(self, func):
        if not func or func.upper() not in ("MAX", "MIN", "SUM", "AVG"):
            raise ApiError("Параметр func має бути одним зі значень: MAX, MIN, SUM, AVG", 400)
        return self.dao.rating_stat(func.upper())[0]

    def split_persons(self):
        return self.dao.split_persons()[0]

    def drop_split_tables(self):
        return self.dao.drop_split_tables()[0]
