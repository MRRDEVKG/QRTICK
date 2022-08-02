from django.core.management.base import BaseCommand
from django.core import serializers
from qrtick_app import models
from datetime import date, datetime


class Command(BaseCommand):
    def handle(self, *args, **options):
        if not models.WorkSchedule.objects.get(id=date.today().weekday()).is_day_off:
            data = models.UserProfile.objects.all()
            for user in data:
                models.ArrivalDeparture.objects.get_or_create(
                   id=(datetime.now().strftime("%d_%m_%Y_") + user.user_id_id),
                    user_id=user, user_id_id=user.user_id_id,
                )


