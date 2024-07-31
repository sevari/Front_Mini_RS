from datetime import timezone
import json
from django.conf import settings
from django.contrib.auth.hashers import make_password
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.parsers import MultiPartParser, FormParser
from django.http import HttpResponseBadRequest, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Conversation, CustomUser, FriendshipRequest, Notification, Post, Message
from django.views.decorators.http import require_POST
import logging
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from PIL import Image
from io import BytesIO
from django.utils.decorators import method_decorator
from django.views import View 
from django.db.models import Q
from django.contrib.auth.decorators import login_required
from .models import Post, Comment
from rest_framework.decorators import api_view
from rest_framework.permissions import IsAuthenticated


from backend import models

User = get_user_model()
logger = logging.getLogger(__name__)


class FriendshipRequestView(APIView):
    def post(self, request, *args, **kwargs):
        from_user = request.user
        to_user_id = request.data.get('to_user_id')

        if not to_user_id:
            return Response({'error': 'Missing to_user_id'}, status=status.HTTP_400_BAD_REQUEST)

        to_user = get_object_or_404(User, id=to_user_id)

        # Vérifier si une demande existe déjà
        existing_request = FriendshipRequest.objects.filter(from_user=from_user, to_user=to_user).first()
        if existing_request:
            return Response({'error': 'Friendship request already exists'}, status=status.HTTP_400_BAD_REQUEST)

        # Créer une nouvelle demande d'ami
        friendship_request = FriendshipRequest.objects.create(from_user=from_user, to_user=to_user)
        return Response({'message': 'Friendship request sent successfully'}, status=status.HTTP_201_CREATED)

class AcceptFriendshipRequestView(APIView):
    def post(self, request, *args, **kwargs):
        from_user_id = request.data.get('from_user_id')

        if not from_user_id:
            return Response({'error': 'Missing from_user_id'}, status=status.HTTP_400_BAD_REQUEST)

        from_user = get_object_or_404(User, id=from_user_id)
        friendship_request = get_object_or_404(FriendshipRequest, from_user=from_user, to_user=request.user)

        # Accepter la demande d'ami
        friendship_request.status = 'accepted'
        friendship_request.save()

        # Créer une relation d'amitié bidirectionnelle si elle n'existe pas déjà
        from_user.friends.add(request.user)
        request.user.friends.add(from_user)

        return Response({'message': 'Friendship request accepted successfully'}, status=status.HTTP_200_OK)

class DeclineFriendshipRequestView(APIView):
    def post(self, request, *args, **kwargs):
        from_user_id = request.data.get('from_user_id')

        if not from_user_id:
            return Response({'error': 'Missing from_user_id'}, status=status.HTTP_400_BAD_REQUEST)

        from_user = get_object_or_404(User, id=from_user_id)
        friendship_request = get_object_or_404(FriendshipRequest, from_user=from_user, to_user=request.user)

        # Refuser la demande d'ami
        friendship_request.status = 'declined'
        friendship_request.save()

        return Response({'message': 'Friendship request declined successfully'}, status=status.HTTP_200_OK)





def get_friends(request, user_id):
    try:
        user = get_object_or_404(User, id=user_id)
        friends = user.friends.all().values('id', 'username', 'profile_picture__url')
        friends_list = list(friends)
        return JsonResponse(friends_list, safe=False)
    except User.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

@csrf_exempt
def add_friend(request, user_id):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            print(f"Request body: {data}")  # Log pour vérifier les données reçues

            friend_id = data.get('friend_id')
            if friend_id is None:
                return JsonResponse({'error': 'Missing friend_id'}, status=400)

            # Vérifier si l'utilisateur avec friend_id existe
            friend_user = get_object_or_404(CustomUser, id=friend_id)

            # Vérifier si l'utilisateur est déjà ami
            user = CustomUser.objects.get(pk=user_id)
            if friend_user in user.friends.all():
                return JsonResponse({'error': 'User is already your friend'}, status=400)

            # Ajouter l'ami à la liste d'amis de l'utilisateur
            user.friends.add(friend_user)

            return JsonResponse({'message': 'Friend added successfully'}, status=200)
        except CustomUser.DoesNotExist:
            return JsonResponse({'error': 'User with given friend_id does not exist'}, status=400)
        except CustomUser.MultipleObjectsReturned:
            return JsonResponse({'error': 'Multiple users found with the given friend_id'}, status=400)
        except Exception as e:
            print(f"Error adding friend: {str(e)}")  # Log pour les erreurs
            return JsonResponse({'error': str(e)}, status=400)
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)

def get_all_users(request, user_id):
    try:
        all_users = User.objects.exclude(id=user_id)
        users_list = [{'id': user.id, 'username': user.username} for user in all_users]
        return JsonResponse(users_list, safe=False)
    except User.DoesNotExist:
        return JsonResponse({'error': 'Users not found'}, status=404)
    
@require_POST
@csrf_exempt
def update_post(request, post_id):
    try:
        post = Post.objects.get(pk=post_id)
    except Post.DoesNotExist:
        return JsonResponse({'error': 'Post not found'}, status=404)
    
    # Vérifiez si l'utilisateur actuel est bien l'auteur de la publication
    if post.author != request.user:
        return HttpResponseBadRequest("You don't have permission to update this post.")

    # Mettez à jour la publication avec les données fournies dans la requête
    content = request.POST.get('content', '')
    image = request.FILES.get('image')
    post.content = content
    if image:
        post.image = image
    post.save()

    return JsonResponse({'message': 'Post updated successfully'}, status=200)

@require_POST
@csrf_exempt
def delete_post(request, post_id):
    try:
        post = Post.objects.get(pk=post_id)
    except Post.DoesNotExist:
        return JsonResponse({'error': 'Post not found'}, status=404)
    
    # Vérifiez si l'utilisateur actuel est bien l'auteur de la publication
    if post.author != request.user:
        return HttpResponseBadRequest("You don't have permission to delete this post.")

    # Supprimez la publication
    post.delete()

    return JsonResponse({'message': 'Post deleted successfully'}, status=200)




@csrf_exempt
def post_list_create(request):
    if request.method == 'GET':
        # Modifier la requête pour trier les publications par date décroissante
        posts = Post.objects.all().order_by('-created_at').values('id', 'author__username', 'content', 'created_at', 'image')
        posts_list = list(posts)
        for post in posts_list:
            if post['image']:
                post['image'] = request.build_absolute_uri(settings.MEDIA_URL + post['image'])
        return JsonResponse(posts_list, safe=False)

    elif request.method == 'POST':
        try:
            author = User.objects.get(username=request.POST['author'])
            content = request.POST.get('content', '')
            image = request.FILES.get('image')
            post = Post.objects.create(author=author, content=content, image=image)
            return JsonResponse({
                'id': post.id, 
                'author': post.author.username, 
                'content': post.content, 
                'created_at': post.created_at,
                'image': request.build_absolute_uri(post.image.url) if post.image else None
            }, status=201)
        except User.DoesNotExist:
            return JsonResponse({'error': 'Author not found'}, status=400)
        except KeyError:
            return JsonResponse({'error': 'Invalid data'}, status=400)
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)

class RegisterView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        username = request.data.get('username')
        password = request.data.get('password')
        first_name = request.data.get('first_name')
        last_name = request.data.get('last_name')

        if not email or not username or not password or not first_name or not last_name:
            return Response({"error": "All fields are required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.create(
                email=email,
                username=username,
                first_name=first_name,
                last_name=last_name,
                password=make_password(password)  # Hash the password
            )
            return Response({"message": "User registered successfully"}, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        password = request.data.get('password')

        user = authenticate(request, email=email, password=password)

        if user is not None:
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user_id': user.id,
            })
        else:
            return Response({"error": "Invalid email or password"}, status=status.HTTP_401_UNAUTHORIZED)

class UploadProfilePictureView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, *args, **kwargs):
        try:
            user = User.objects.get(email=request.data['email'])
            user.profile_picture = request.data['profile_picture']
            user.save()
            return Response({"success": "Profile picture uploaded successfully"}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

class CreatePostAPIView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, *args, **kwargs):
        content = request.data.get('content')
        image = request.FILES.get('image')
        author_email = request.data.get('author')

        if not content:
            return Response({'message': 'Veuillez fournir un contenu pour la publication'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            author = User.objects.get(email=author_email)
        except User.DoesNotExist:
            return Response({'message': 'Auteur non trouvé'}, status=status.HTTP_400_BAD_REQUEST)

        post = Post.objects.create(content=content, author=author, image=image)

        # Construire l'URL complète de l'image
        image_url = request.build_absolute_uri(post.image.url) if post.image else None

        post_data = {
            'id': post.id,
            'content': post.content,
            'author': post.author.username,
            'image_url': image_url
        }
        return Response(post_data, status=status.HTTP_201_CREATED)
    

def validate_image(file):
    try:
        img = Image.open(file)
        img.verify()
        return True
    except Exception:
        return False


@csrf_exempt
def send_message(request):
    if request.method == 'POST':
        sender_id = request.POST.get('sender_id')
        recipient_id = request.POST.get('recipient_id')
        content = request.POST.get('content', '')
        image = request.FILES.get('image')
        file = request.FILES.get('file')

        sender = get_object_or_404(CustomUser, id=sender_id)
        recipient = get_object_or_404(CustomUser, id=recipient_id)

        # Ensure user1_id is always the smaller id to avoid duplicate conversations
        user1_id = min(sender_id, recipient_id)
        user2_id = max(sender_id, recipient_id)

        # Fetch or create conversation
        conversation, created = Conversation.objects.get_or_create(
            user1_id=user1_id,
            user2_id=user2_id
        )

        # Create message
        message = Message(
            sender=sender,
            recipient=recipient,
            content=content,
            image=image,
            file=file,
            type='image' if image else 'file' if file else 'text',
            conversation=conversation
        )
        message.save()  # This triggers the incrementation of unread counts in Message's save() method

        # Update last message in conversation
        conversation.last_message = content
        conversation.last_message_time = message.created_at
        conversation.last_message_sender = sender  # Mark the sender of the last message
        conversation.last_message_sent = True  # Mark the message as sent
        conversation.save()

        # Create notification for the recipient
        notification_message = f'{sender.username} vous a envoyé un message'
        notification = Notification.objects.create(
            recipient=recipient,
            sender=sender,
            message=notification_message
        )

        return JsonResponse({'message': 'Message sent successfully'}, status=201)
    else:
        return JsonResponse({'error': 'Invalid request method.'}, status=400)



@csrf_exempt
def get_messages(request, user_id):
    if request.method == 'GET':
        user = get_object_or_404(CustomUser, id=user_id)

        sent_messages = Message.objects.filter(sender=user).order_by('-created_at')
        received_messages = Message.objects.filter(recipient=user).order_by('-created_at')

        messages_data = []

        for message in sent_messages.union(received_messages).order_by('-created_at'):
            messages_data.append({
                'id': message.id,
                'sender': message.sender.username,
                'recipient': message.recipient.username,
                'content': message.content,
                'created_at': message.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'image_url': message.image.url if message.image else None
            })

        return JsonResponse(messages_data, safe=False)

    return JsonResponse({'error': 'Invalid request method'}, status=400)


@csrf_exempt
def get_messages_between_users(request, sender_id, recipient_id):
    if request.method == 'GET':
        sender = get_object_or_404(CustomUser, id=sender_id)
        recipient = get_object_or_404(CustomUser, id=recipient_id)

        messages = Message.objects.filter(
            Q(sender=sender, recipient=recipient) | Q(sender=recipient, recipient=sender)
        ).order_by('-created_at')

        page = int(request.GET.get('page', 1))
        page_size = 20
        start = (page - 1) * page_size
        end = start + page_size
        paginated_messages = messages[start:end]

        message_list = [{
            'id': msg.id,
            'sender': msg.sender.id,
            'recipient': msg.recipient.id,
            'content': msg.content,
            'image_url': msg.image.url if msg.image else None,
            'file_url': msg.file.url if msg.file else None,
            # 'created_at': msg.created_at.isoformat(),
            'type': msg.type
        } for msg in paginated_messages]

        has_more = end < messages.count()

        return JsonResponse({'messages': message_list, 'has_more': has_more}, safe=False)
    else:
        return JsonResponse({'error': 'Invalid request method.'}, status=400)
    


def get_conversation(request, conversation_id):
    conversation = get_object_or_404(Conversation, id=conversation_id)
    conversation_data = {
        'user1_id': conversation.user1_id,
        'user1_username': conversation.user1.username,
        'user2_id': conversation.user2_id,
        'user2_username': conversation.user2.username,
        'last_message': conversation.last_message,
        'last_message_time': conversation.last_message_time.strftime('%Y-%m-%d %H:%M:%S') if conversation.last_message_time else None,
    }

    return JsonResponse(conversation_data)
    


def list_conversations(request):
    user_id = request.GET.get('user_id')
    
    try:
        if not user_id:
            return JsonResponse({'error': 'Missing user_id parameter'}, status=400)
        
        user_id = int(user_id)
        
        user = get_object_or_404(CustomUser, id=user_id)
        
        conversations = Conversation.objects.filter(Q(user1=user) | Q(user2=user))
        conversations_data = []
        
        for conversation in conversations:
            if conversation.user1 == user:
                other_user = conversation.user2
                unread_count = conversation.user1_unread_count
            else:
                other_user = conversation.user1
                unread_count = conversation.user2_unread_count

            last_message_sender_id = conversation.last_message_sender.id if conversation.last_message_sender else None

            conversation_data = {
                'conversation_id': conversation.id,
                'other_user_id': other_user.id,
                'other_username': other_user.username,
                'last_message': conversation.last_message,
                'last_message_time': conversation.last_message_time.strftime("%Y-%m-%d %H:%M:%S") if conversation.last_message_time else None,
                'unread_count': unread_count,
                'is_message_sent': conversation.last_message_sent,
                'profile_image_url': other_user.profile_picture.url if other_user.profile_picture else None,
                'last_message_sender_id': last_message_sender_id,
            }
            conversations_data.append(conversation_data)
        
        return JsonResponse(conversations_data, safe=False)
    
    except ValueError:
        return JsonResponse({'error': 'Invalid user_id format'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


@csrf_exempt
def mark_messages_as_read(request):
    if request.method == 'POST':
        user_id = request.POST.get('user_id')
        conversation_id = request.POST.get('conversation_id')

        if not user_id or not conversation_id:
            return JsonResponse({'error': 'Missing user_id or conversation_id parameter'}, status=400)

        try:
            user_id = int(user_id)
            conversation_id = int(conversation_id)

            user = get_object_or_404(CustomUser, id=user_id)
            conversation = get_object_or_404(Conversation, id=conversation_id)

            if conversation.user1 == user:
                conversation.user1_unread_count = 0
            elif conversation.user2 == user:
                conversation.user2_unread_count = 0

            conversation.save()
            return JsonResponse({'message': 'Messages marked as read'}, status=200)
        except ValueError:
            return JsonResponse({'error': 'Invalid user_id or conversation_id format'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    else:
        return JsonResponse({'error': 'Invalid request method.'}, status=400)


@csrf_exempt
def unread_messages_count(request):
    if request.method == 'GET':
        user_id = request.GET.get('user_id')
        if not user_id:
            return JsonResponse({'error': 'Missing user_id parameter'}, status=400)
        
        try:
            user = get_object_or_404(CustomUser, id=user_id)
            unread_count = Message.objects.filter(recipient=user, read=False).count()
            return JsonResponse({'count': unread_count}, status=200)
        except CustomUser.DoesNotExist:
            return JsonResponse({'error': 'User not found'}, status=404)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=400)
    

# @api_view(['POST'])
# @permission_classes([IsAuthenticated])
def like_post(request, post_id):
    try:
        post = Post.objects.get(id=post_id)
        user = request.user
        if user in post.likes.all():
            post.likes.remove(user)
            message = 'Unliked'
        else:
            post.likes.add(user)
            message = 'Liked'
        post.save()
        return Response({"message": message}, status=status.HTTP_200_OK)
    except Post.DoesNotExist:
        return Response({"error": "Post not found"}, status=status.HTTP_404_NOT_FOUND)


def list_comments(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    comments = post.comments.all()
    serialized_comments = [{'author': comment.author.username, 'content': comment.content} for comment in comments]
    return JsonResponse(serialized_comments, status=200, safe=False)

def add_comment(request, post_id):
    post = get_object_or_404(Post, id=post_id)

    if request.method == 'POST':
        content = request.POST.get('content', '')

        comment = Comment.objects.create(
            post=post,
            author=request.user,
            content=content
        )

        return JsonResponse({'message': 'Comment added successfully'}, status=201)

    return JsonResponse({'error': 'Invalid request method.'}, status=400)


@api_view(['GET'])
def get_notifications(request, user_id):
    notifications = Notification.objects.filter(recipient_id=user_id, read=False)
    data = [{"sender": n.sender.username, "message": n.message, "timestamp": n.timestamp} for n in notifications]
    return Response(data)



@csrf_exempt
def get_notifications(request, user_id):
    user = get_object_or_404(CustomUser, id=user_id)
    notifications = Notification.objects.filter(recipient=user, read=False).order_by('-timestamp')
    
    notification_list = [{
        'id': notification.id,
        'sender': notification.sender.username,
        'message': notification.message,
        'timestamp': notification.timestamp.isoformat(),
    } for notification in notifications]
    
    return JsonResponse(notification_list, safe=False)

@csrf_exempt
def mark_notification_as_read(request, notification_id):
    notification = get_object_or_404(Notification, id=notification_id)
    notification.read = True
    notification.save()
    return JsonResponse({'message': 'Notification marked as read.'})


@csrf_exempt
def list_notifications(request, user_id):
    if request.method == 'GET':
        user = get_object_or_404(CustomUser, id=user_id)

        # Récupérer les notifications pour l'utilisateur spécifié
        notifications = Notification.objects.filter(recipient=user).order_by('-timestamp')

        # Créer une liste JSON des notifications
        notification_list = []
        for notification in notifications:
            notification_data = {
                'id': notification.id,
                'sender': {
                    'id': notification.sender.id,
                    'username': notification.sender.username,
                    'profile_picture': request.build_absolute_uri(notification.sender.profile_picture.url) if notification.sender.profile_picture else None,
                },
                'message': notification.message,
                'timestamp': notification.timestamp.strftime('%Y-%m-%d %H:%M:%S'),
                'read': notification.read,
            }
            notification_list.append(notification_data)

        return JsonResponse(notification_list, safe=False)
    else:
        return JsonResponse({'error': 'Invalid request method.'}, status=400)
    
@csrf_exempt
def notifications_for_user(request, user_id):
    if request.method == 'GET':
        user = get_object_or_404(CustomUser, id=user_id)
        notifications = Notification.objects.filter(recipient=user).order_by('-timestamp')
        
        notification_list = []
        for notification in notifications:
            notification_data = {
                'sender_username': notification.sender.username,
                'message': notification.message,
                'timestamp': notification.timestamp.strftime('%Y-%m-%d %H:%M:%S'),
            }
            notification_list.append(notification_data)
        
        return JsonResponse(notification_list, safe=False)
    else:
        return JsonResponse({'error': 'Invalid request method.'}, status=400)

def notifications(request):
    if request.method == 'GET':
        recipient_id = request.GET.get('recipient_id')
        
        if recipient_id is not None:
            try:
                notifications = Notification.objects.filter(recipient_id=recipient_id).order_by('-timestamp')
                data = []
                for notification in notifications:
                    data.append({
                        'senderName': notification.sender.username,  # Remplacez par le champ correct de l'expéditeur
                        'message': notification.message,
                        'timestamp': notification.timestamp.isoformat(),  # Assurez-vous de formater correctement le timestamp
                    })
                return JsonResponse(data, safe=False)
            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)
        else:
            return JsonResponse({'error': 'Missing recipient_id parameter'}, status=400)
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=405)


@csrf_exempt
def notifications_list(request):
    if request.method == 'GET':
        recipient_id = request.GET.get('recipient_id')
        recipient = get_object_or_404(CustomUser, id=recipient_id)

        notifications = Notification.objects.filter(recipient=recipient).order_by('-timestamp')

        notification_list = []
        for notification in notifications:
            notification_list.append(notification.message)

        return JsonResponse(notification_list, safe=False)
    else:
        return JsonResponse({'error': 'Invalid request method.'}, status=400)

def unread_notifications_count(request):
    if request.method == 'GET':
        user_id = request.GET.get('user_id')

        if user_id is not None:
            try:
                # Compter les notifications non lues pour l'utilisateur spécifié
                unread_count = Notification.objects.filter(recipient_id=user_id, read=False).count()
                return JsonResponse({'count': unread_count})

            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)

        else:
            return JsonResponse({'error': 'Missing user_id parameter'}, status=400)

    else:
        return JsonResponse({'error': 'Invalid request method'}, status=405)

class NotificationListView(View):
    def get(self, request):
        recipient_id = request.GET.get('recipient_id')
        notifications = Notification.objects.filter(recipient_id=recipient_id)

        notification_list = [
            {
                'senderName': notification.sender.username,
                'message': notification.message,
                'timestamp': notification.timestamp.isoformat(),
            }
            for notification in notifications
        ]

        return JsonResponse(notification_list, safe=False)
    
def get_user_info(request, user_id):
    user = get_object_or_404(User, id=user_id)
    username = user.username
    email = user.email
    return JsonResponse({'username': username, 'email': email})


@method_decorator(csrf_exempt, name='dispatch')
class UpdateUserInfoView(View):
    def patch(self, request, user_id):
        try:
            user = CustomUser.objects.get(pk=user_id)
        except CustomUser.DoesNotExist:
            return JsonResponse({'error': 'User not found'}, status=404)

        data = json.loads(request.body)

        username = data.get('username')
        if username:
            user.username = username

        user.save()

        return JsonResponse({'message': 'User updated successfully'}, status=200)