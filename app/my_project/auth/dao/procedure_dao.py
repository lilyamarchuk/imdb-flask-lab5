from datetime import date, datetime
from decimal import Decimal

from sqlalchemy import text

from my_project.utils.db import db


def _clean(row):
    for key, value in row.items():
        if isinstance(value, (date, datetime)):
            row[key] = value.isoformat()
        elif isinstance(value, Decimal):
            row[key] = float(value)
    return row


class ProcedureDAO:
    def _call(self, sql, params=None):
        result = db.session.execute(text(sql), params or {})
        rows = [_clean(dict(r._mapping)) for r in result] if result.returns_rows else []
        db.session.commit()
        return rows

    def insert_person(self, full_name, birth_date, birth_place, biography):
        return self._call(
            "CALL sp_insert_person(:full_name, :birth_date, :birth_place, :biography)",
            {"full_name": full_name, "birth_date": birth_date,
             "birth_place": birth_place, "biography": biography},
        )

    def add_movie_genre(self, movie_title, genre_name):
        return self._call("CALL sp_add_movie_genre(:title, :genre)",
                          {"title": movie_title, "genre": genre_name})

    def add_movie_country(self, movie_title, country_name):
        return self._call("CALL sp_add_movie_country(:title, :country)",
                          {"title": movie_title, "country": country_name})

    def insert_noname_genres(self):
        return self._call("CALL sp_insert_noname_genres()")

    def delete_noname_genres(self):
        return self._call("CALL sp_delete_noname_genres()")

    def rating_stat(self, func):
        return self._call("CALL sp_rating_stat(:func)", {"func": func})

    def split_persons(self):
        return self._call("CALL sp_split_persons_by_cursor()")

    def drop_split_tables(self):
        return self._call("CALL sp_drop_split_tables()")
