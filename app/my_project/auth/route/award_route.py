from my_project.auth.controller.award_controller import AwardController
from my_project.auth.route.base_route import create_crud_blueprint

award_bp = create_crud_blueprint("awards", "/api/awards", AwardController())
