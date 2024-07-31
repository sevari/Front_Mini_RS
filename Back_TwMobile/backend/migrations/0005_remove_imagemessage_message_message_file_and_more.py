# Generated by Django 4.2.13 on 2024-06-22 14:27

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backend', '0004_imagemessage_filemessage'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='imagemessage',
            name='message',
        ),
        migrations.AddField(
            model_name='message',
            name='file',
            field=models.FileField(blank=True, null=True, upload_to='message_files/'),
        ),
        migrations.AddField(
            model_name='message',
            name='image',
            field=models.ImageField(blank=True, null=True, upload_to='message_images/'),
        ),
        migrations.DeleteModel(
            name='FileMessage',
        ),
        migrations.DeleteModel(
            name='ImageMessage',
        ),
    ]