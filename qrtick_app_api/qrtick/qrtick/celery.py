from __future__ import absolute_import, unicode_literals
import os

from celery import Celery
from celery.schedules import crontab


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'qrtick.settings')

app = Celery('qrtick')

# Celery beat settings
app.config_from_object('qrtick.celeryconfig')

# Celery Schedules - https://docs.celeryproject.org/en/stable/reference/celery.schedules.html

app.autodiscover_tasks()


@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
'''
from django_celery_beat.models import PeriodicTask, CrontabSchedule
from qrtick_app.models import WorkSchedule

for day in ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'):
    PeriodicTask.objects.get_or_create(
        name=day,
        crontab=CrontabSchedule.objects.get_or_create(
            minute='1',
            hour='*',
            day_of_week=day,
            day_of_month='*',
            month_of_year='*',
        ),
        task='qrtick_app.tasks.create_daily_attendance_sheet',
        enabled=False,
    )

    WorkSchedule.objects.get_or_create(
        day_of_week=day,
        is_dayoff=True,
    )
'''