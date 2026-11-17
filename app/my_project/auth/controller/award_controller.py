from my_project.auth.controller.base_controller import BaseController
from my_project.auth.service.award_service import AwardService


class AwardController(BaseController):
    def __init__(self):
        super().__init__(AwardService())
