# Generated by Django 4.2.13 on 2024-06-20 06:32

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backend', '0002_remove_message_read_status_message_is_read_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='message',
            name='is_read',
        ),
        migrations.RemoveField(
            model_name='message',
            name='notification_sent',
        ),
        migrations.AddField(
            model_name='message',
            name='read_status',
            field=models.IntegerField(default=0),
        ),
    ]
