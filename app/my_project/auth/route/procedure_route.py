from flask import Blueprint

from my_project.auth.controller.procedure_controller import ProcedureController

controller = ProcedureController()
procedure_bp = Blueprint("procedures", __name__, url_prefix="/api/procedures")

procedure_bp.add_url_rule("/insert-person", "insert_person", controller.insert_person, methods=["POST"])
procedure_bp.add_url_rule("/movie-genre", "movie_genre", controller.add_movie_genre, methods=["POST"])
procedure_bp.add_url_rule("/movie-country", "movie_country", controller.add_movie_country, methods=["POST"])
procedure_bp.add_url_rule("/noname-genres", "noname_insert", controller.insert_noname_genres, methods=["POST"])
procedure_bp.add_url_rule("/noname-genres", "noname_delete", controller.delete_noname_genres, methods=["DELETE"])
procedure_bp.add_url_rule("/rating-stat", "rating_stat", controller.rating_stat, methods=["GET"])
procedure_bp.add_url_rule("/split-persons", "split_persons", controller.split_persons, methods=["POST"])
procedure_bp.add_url_rule("/split-persons", "drop_split", controller.drop_split_tables, methods=["DELETE"])
