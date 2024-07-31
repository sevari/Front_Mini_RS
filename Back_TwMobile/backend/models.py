from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.conf import settings
from django.utils import timezone
from django.contrib.auth import get_user_model




class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)

class CustomUser(AbstractBaseUser, PermissionsMixin):
    
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=150, blank=True)
    first_name = models.CharField(max_length=30, blank=True)
    last_name = models.CharField(max_length=30, blank=True)
    date_joined = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    friends = models.ManyToManyField('self', through='Friendship', symmetrical=False, related_name='related_to')
    objects = CustomUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.email

class Post(models.Model):
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    content = models.TextField()
    image = models.ImageField(upload_to='post_images/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    likes = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='liked_posts', blank=True)
    shares = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='shared_posts', blank=True)
    likes_count = models.IntegerField(default=0)  # Champ pour compter les likes

    def __str__(self):
        return self.title

class Comment(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Comment by {self.author} on {self.post.title}'
    

class Friendship(models.Model):
    user1 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='friendship_user1')
    user2 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='friendship_user2')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['user1', 'user2']

class FriendshipRequest(models.Model):
    from_user = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='friendship_requests_sent', on_delete=models.CASCADE)
    to_user = models.ForeignKey(settings.AUTH_USER_MODEL, related_name='friendship_requests_received', on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=[
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('declined', 'Declined')
    ], default='pending')

    class Meta:
        unique_together = ['from_user', 'to_user']

class Conversation(models.Model):
    user1 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='conversations_as_user1')
    user2 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='conversations_as_user2')
    last_message = models.TextField(blank=True, null=True)
    last_message_time = models.DateTimeField(blank=True, null=True)
    last_message_sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name='last_message_sender')
    last_message_sent = models.BooleanField(default=False)
    user1_unread_count = models.IntegerField(default=0)
    user2_unread_count = models.IntegerField(default=0)

    def __str__(self):
        return f"Conversation between {self.user1} and {self.user2}"

    def mark_as_read(self, user):
        if user == self.user1:
            self.user1_unread_count = 0
        elif user == self.user2:
            self.user2_unread_count = 0
        self.save()

    def get_other_user(self, user):
        """Return the other user in the conversation."""
        if user == self.user1:
            return self.user2
        elif user == self.user2:
            return self.user1
        return None

    def get_unread_count_for_user(self, user):
        """Return unread count for the given user."""
        if user == self.user1:
            return self.user1_unread_count
        elif user == self.user2:
            return self.user2_unread_count
        return 0

    def increment_unread_count_for_user(self, user):
        """Increment unread count for the given user."""
        if user == self.user1:
            self.user1_unread_count += 1
        elif user == self.user2:
            self.user2_unread_count += 1
        self.save()

    def reset_unread_count_for_user(self, user):
        """Reset unread count for the given user."""
        if user == self.user1:
            self.user1_unread_count = 0
        elif user == self.user2:
            self.user2_unread_count = 0
        self.save()



class Message(models.Model):
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='sent_messages')
    recipient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='received_messages')
    content = models.TextField(blank=True)
    image = models.ImageField(upload_to='message_images/', blank=True, null=True)
    file = models.FileField(upload_to='message_files/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    type = models.CharField(max_length=20, default='text')
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    read = models.BooleanField(default=False)  # Nouveau champ pour indiquer si le message est lu

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        
        # Mettre à jour le compteur de messages non lus dans la conversation basée sur le destinataire
        if self.recipient == self.conversation.user1:
            self.conversation.user1_unread_count += 1
        elif self.recipient == self.conversation.user2:
            self.conversation.user2_unread_count += 1
        self.conversation.save()

    def __str__(self):
        return f'Message {self.id} from {self.sender} to {self.recipient}'
    

class Notification(models.Model):
    recipient = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='notifications')
    sender = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='sent_notifications')
    message = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    read = models.BooleanField(default=False)

    def __str__(self):
        return f'{self.sender.username} sent a message to {self.recipient.username}'



