from rest_framework import permissions
from django.contrib.auth.models import AnonymousUser


class UpdateOwnAuthorization(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.user.is_staff:
            return True
        else:
            if request.method in permissions.SAFE_METHODS:
                return True

            return obj.id == request.user.id


class UpdateOwnProfile(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        elif not isinstance(request.user, AnonymousUser):
            return True
        else:
            return False


class UpdateWorkSchedule(permissions.IsAuthenticated):
    def has_object_permission(self, request, view, obj):
        if request.method in ('POST', 'DELETE'):
            return False
        elif request.method in ('GET',):
            return True
        elif request.method in ('PUT', 'PATCH') and request.user.is_staff:
            return True
        else:
            return False


class UpdateArrivalTime(permissions.IsAuthenticated):
    def has_object_permission(self, request, view, obj):
        return obj.user_id_id == request.user.user_id