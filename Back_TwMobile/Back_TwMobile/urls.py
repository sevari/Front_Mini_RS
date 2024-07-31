
from django.conf import settings
from django.contrib import admin
from django.urls import path, include
from backend import views
from backend.views import AcceptFriendshipRequestView, CreatePostAPIView, DeclineFriendshipRequestView, FriendshipRequestView, NotificationListView, RegisterView, LoginView, UpdateUserInfoView, UploadProfilePictureView, delete_post, get_all_users, get_friends, get_user_info, list_notifications, mark_messages_as_read, unread_messages_count, update_post
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from django.conf.urls.static import static


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('backend.urls')),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('inscription/', RegisterView.as_view(), name='inscription'),
    path('login/', LoginView.as_view(), name='login'),
    path('upload/', UploadProfilePictureView.as_view(), name='upload'),
    path('posts/', views.post_list_create, name='post_list_view'),
    path('create_post/', CreatePostAPIView.as_view(), name='create_post'),
    path('posts/<int:post_id>/update/', update_post, name='post-update'),
    path('posts/<int:post_id>/delete/', delete_post, name='post-delete'),
    path('users/<str:username>/friends/', get_friends, name='get_friends'),
    path('users/<int:user_id>/add_friend/', views.add_friend, name='add_friend'),
    path('users/<int:user_id>/all/', get_all_users, name='get_all_users'),
    path('send_friend_request/', FriendshipRequestView.as_view(), name='send_friend_request'),
    path('accept_friend_request/', AcceptFriendshipRequestView.as_view(), name='accept_friend_request'),
    path('decline_friend_request/', DeclineFriendshipRequestView.as_view(), name='decline_friend_request'),
    path('send_message/', views.send_message, name='send_message'),
    path('get_messages/<int:user_id>/', views.get_messages, name='get_messages'),
    path('get_messages_between_users/<int:sender_id>/<int:recipient_id>/', views.get_messages_between_users, name='get_messages_between_users'),
    path('conversation/<int:conversation_id>/', views.get_conversation, name='get_conversation'),
    path('conversations/', views.list_conversations, name='list_conversations'),
    path('mark_messages_as_read/',  mark_messages_as_read, name='mark_messages_as_read'), 
    path('unread_messages_count/', unread_messages_count, name='unread_messages_count'),
    path('posts/<int:post_id>/like/', views.like_post, name='like_post'),
    path('posts/<int:post_id>/comments/', views.list_comments, name='list_comments'),
    path('posts/<int:post_id>/comments/add/', views.add_comment, name='add_comment'),
    path('notifications/<int:user_id>/', views.get_notifications),  
    path('notifications/<int:user_id>/', list_notifications, name='list_notifications'),
    path('notifications/<int:user_id>/', views.notifications_for_user, name='notifications_for_user'),
    path('notifications/', views.notifications_list, name='notifications_list'),
    path('unread_notifications_count/', views.unread_notifications_count, name='unread_notifications_count'),
    path('notifications/', NotificationListView.as_view(), name='notifications_list'),
    path('get_user_info/<int:user_id>/', get_user_info, name='get_user_info'),
    path('update_user_info/<int:user_id>/', UpdateUserInfoView.as_view(), name='update_user_info'),
        
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
