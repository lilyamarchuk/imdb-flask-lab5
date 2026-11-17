from flask import jsonify, request

from my_project.auth.service.procedure_service import ProcedureService


class ProcedureController:
    def __init__(self):
        self.service = ProcedureService()

    def insert_person(self):
        return jsonify(self.service.insert_person(request.get_json(silent=True))), 201

    def add_movie_genre(self):
        return jsonify(self.service.add_movie_genre(request.get_json(silent=True))), 201

    def add_movie_country(self):
        return jsonify(self.service.add_movie_country(request.get_json(silent=True))), 201

    def insert_noname_genres(self):
        return jsonify(self.service.insert_noname_genres()), 201

    def delete_noname_genres(self):
        return jsonify(self.service.delete_noname_genres())

    def rating_stat(self):
        return jsonify(self.service.rating_stat(request.args.get("func")))

    def split_persons(self):
        return jsonify(self.service.split_persons()), 201

    def drop_split_tables(self):
        return jsonify(self.service.drop_split_tables())
