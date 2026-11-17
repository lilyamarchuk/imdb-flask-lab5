from flask import Blueprint

from my_project.auth.controller.movie_delete_log_controller import MovieDeleteLogController

controller = MovieDeleteLogController()
log_bp = Blueprint("movie_delete_log", __name__, url_prefix="/api/movie-delete-log")
log_bp.add_url_rule("", "get_all", controller.get_all, methods=["GET"])
log_bp.add_url_rule("/<int:item_id>", "get_one", controller.get_one, methods=["GET"])
