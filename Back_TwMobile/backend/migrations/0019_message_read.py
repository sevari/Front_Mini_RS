# Generated by Django 4.2.13 on 2024-06-26 13:15

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backend', '0018_conversation_last_message_sent_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='message',
            name='read',
            field=models.BooleanField(default=False),
        ),
    ]