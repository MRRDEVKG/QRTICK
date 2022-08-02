from django.contrib import admin
from qrtick_app import models

admin.site.register(models.UserAuthentication)
admin.site.register(models.UserProfile)
admin.site.register(models.ArrivalDeparture)
admin.site.register(models.WorkSchedule)
admin.site.register(models.QRCODE)

