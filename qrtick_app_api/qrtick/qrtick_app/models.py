import os
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.auth.models import PermissionsMixin
from django.contrib.auth.models import BaseUserManager
from django.conf import settings
from phonenumber_field.modelfields import PhoneNumberField

from django_celery_beat.models import PeriodicTask


# Create your models here.
class UserAuthenticationManager(BaseUserManager):
    def create_user(self,  user_id, password=None, is_staff=False):
        if len(str(password)) < 7:
            raise ValueError('Password must be at least 7 characters long')

        user = self.model(user_id=user_id, is_staff=is_staff)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, user_id, password):
        user = self.create_user(user_id, password, True)

        user.is_superuser = True
        user.save(using=self._db)

        return user


class UserAuthentication(AbstractUser, PermissionsMixin):
    user_id = models.CharField(verbose_name="user id", max_length=10, unique=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    username = None
    first_name = None
    last_name = None
    email = None

    objects = UserAuthenticationManager()

    USERNAME_FIELD = 'user_id'
    REQUIRED_FIELDS = []

    def get_full_name(self):
        return self.user_id

    def get_short_name(self):
        return self.user_id

    def __str__(self):
        return self.user_id


def user_profile_image_file_path(instance, filename):
    ext = filename.split('.')[-1]
    filename = f'{instance.pk}.{ext}'
    return os.path.join('uploads/profile_images/', filename)


class UserProfile(models.Model):
    user_id = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, primary_key=True, to_field='user_id', related_name='profile')
    name = models.CharField(max_length=50)
    surname = models.CharField(max_length=50)
    department = models.CharField(max_length=100)
    designation = models.CharField(max_length=100)
    employed_date = models.DateField(null=True)
    skills = models.TextField(max_length=50, null=True)
    address = models.CharField(max_length=100, null=True)
    phone_number = PhoneNumberField(null=True)
    email = models.EmailField(null=True)
    date_of_birth = models.DateField(null=True)
    about_me = models.TextField(max_length=100, null=True)
    profile_image = models.ImageField(null=True, upload_to=user_profile_image_file_path)

    def __str__(self):
        return f'{self.user_id}_{self.name}_{self.surname}'


class ArrivalDeparture(models.Model):
    id = models.CharField(max_length=20, primary_key=True)
    user_id = models.ForeignKey(UserProfile, on_delete=models.CASCADE, unique=False, to_field='user_id_id', related_name='attendances')
    date = models.DateField(auto_now_add=True)
    present = models.BooleanField(default=False)

    arrival_time = models.TimeField(null=True)
    arrival_time_difference = models.IntegerField(null=True)

    departure_time = models.TimeField(null=True)
    departure_time_difference = models.IntegerField(null=True)

    total_time = models.FloatField(default=0)

    def __str__(self):
        return self.id


class WorkSchedule(models.Model):
    id = models.IntegerField(default=0, primary_key=True)
    day_of_week = models.CharField(max_length=10, null=False)
    from_time = models.TimeField(null=True)
    to_time = models.TimeField(null=True)
    is_day_off = models.BooleanField(default=False)

    def __str__(self):
        return self.day_of_week


class QRCODE(models.Model):
    id = models.CharField(default='qr_code_id', primary_key=True, max_length=20)
    qr_code = models.CharField(max_length=1000, default='')


