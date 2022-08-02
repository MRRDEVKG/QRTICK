from celery.schedules import crontab

broker_url = 'redis://redis:6379/0'
backend_url = 'redis://redis:6379/1'
accept_content = ['application/json']
task_serializer = 'json'
result_serializer = 'json'
beat_scheduler = 'django_celery_beat.schedulers:DatabaseScheduler'
timezone = 'Europe/Istanbul'
enable_utc = False
imports = ['qrtick_app.tasks']

beat_schedule = {
    'Every_2_hour_00:00': {
        'task': 'qrtick_app.tasks.create_daily_attendance_sheet',
        'schedule': crontab(minute='0', hour='*/2', day_of_week='*')
    }
}
