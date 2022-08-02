from celery import shared_task
from celery.utils.log import get_task_logger
from django.core import management

logger = get_task_logger(__name__)


@shared_task
def create_daily_attendance_sheet():
    logger.info('Creating daily attendance sheet...')
    management.call_command(command_name='create_daily_attendance_list',)

