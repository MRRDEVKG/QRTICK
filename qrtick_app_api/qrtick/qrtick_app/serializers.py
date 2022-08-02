import this

from rest_framework import serializers
from qrtick_app import models
from datetime import time, timedelta, datetime, date




class ArrivalDepartureSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.ArrivalDeparture
        fields = '__all__'

        ordering = ('-date',)
        extra_kwargs = {
            'id': {
              'read_only': True
            },
            'user_id': {
                'read_only': True,
            },
            'date': {
                'read_only': True,
            },
            'present': {
                'read_only': True,
            },
            'arrival_time_difference': {
                'read_only': True,
            },
            'departure_time_difference': {
                'read_only': True,
            },
            'total_time': {
                'read_only': True,
            },
        }

    def update(self, instance, validated_data):

        if instance.present is False and validated_data.get('arrival_time') == time(minute=0, hour=0):
            arrival_time = datetime.now().time()
            schedule_time = models.WorkSchedule.objects.get(id=datetime.now().weekday()).from_time
            time_diff = (datetime.combine(date.today(), schedule_time) - datetime.combine(date.today(), arrival_time)).total_seconds()/60

            instance.arrival_time = arrival_time
            instance.arrival_time_difference = int(time_diff)
            print("check")

            instance.present = True

        elif instance.present is True and validated_data.get('arrival_time') == time(minute=12, hour=12) and instance.departure_time is None:
            departure_time = datetime.now().time()
            schedule_time = models.WorkSchedule.objects.get(id=datetime.now().weekday()).to_time
            time_diff = (datetime.combine(date.today(), departure_time) - datetime.combine(date.today(), schedule_time)).total_seconds() / 60

            instance.departure_time = departure_time
            instance.departure_time_difference = int(time_diff)
            instance.total_time = (datetime.combine(date.today(), departure_time) - datetime.combine(date.today(), instance.arrival_time)).total_seconds()/3600
        else:
            return None

        instance.save()
        return instance


class UserProfileSerializer(serializers.ModelSerializer):
    attendances = ArrivalDepartureSerializer(many=True, read_only=True,   )

    class Meta:
        model = models.UserProfile
        fields = '__all__'

        extra_kwargs = {
            'user_id': {
                'read_only': True,
            }
        }

    def create(self, validated_data):
        next_id = 1
        if models.UserAuthentication.objects.last() is not None:
            next_id = models.UserAuthentication.objects.last().id + 1

        user_id = validated_data['department'][0] + validated_data['designation'][0] + validated_data['name'][0] + validated_data['surname'][0] + f'{next_id:03}'
        user = models.UserAuthentication.objects.create_user(
            user_id=user_id,
            password=user_id
        )

        user_profile = models.UserProfile.objects.create(
            user_id=user,
            name=validated_data['name'],
            surname=validated_data['surname'],
            department=validated_data['department'],
            designation=validated_data['designation'],
            employed_date=validated_data['employed_date'],
            skills=validated_data['skills'],
            address=validated_data['address'],
            phone_number=validated_data['phone_number'],
            email=validated_data['email'],
            date_of_birth=validated_data['date_of_birth'],
            about_me=validated_data['about_me'],
            profile_image=validated_data['profile_image']
        )

        return user_profile


class UserAuthenticationSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(many=False, read_only=True)

    class Meta:
        model = models.UserAuthentication
        fields = ('id', 'user_id', 'password', 'is_staff', 'profile')
        extra_kwargs = {
            'password': {
                'write_only': True,
                'style': {'input_type': 'password'}
            }
        }

    def create(self, validated_data):
        user = models.UserAuthentication.objects.create_user(
            user_id=validated_data['user_id'],
            password=validated_data['password'],
            is_staff=validated_data['is_staff']
        )

        return user


class WorkScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.WorkSchedule
        fields = '__all__'
        extra_kwargs = {
            'id': {
                'read_only': True,
            },
            'day_of_week': {
                'read_only': True,
            }
        }


class QRCODESerializer(serializers.ModelSerializer):
    class Meta:
        model = models.QRCODE
        fields = '__all__'
        extra_kwargs = {
            'id': {
                'read_only': True,
            }
        }


class CheckQRCODESerializer(serializers.Serializer):
    scanned_qr_code = serializers.CharField(max_length=1000)


class IsStaffSerializer(serializers.Serializer):
    user_id = serializers.CharField(max_length=10)

