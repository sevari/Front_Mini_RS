# Generated by Django 4.2.13 on 2024-06-23 15:44

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backend', '0010_remove_message_image_message_image_url_and_more'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='message',
            options={'ordering': ('-created_at',)},
        ),
        migrations.RemoveField(
            model_name='message',
            name='image_url',
        ),
        migrations.RemoveField(
            model_name='message',
            name='type',
        ),
        migrations.AddField(
            model_name='message',
            name='image',
            field=models.ImageField(blank=True, null=True, upload_to='message_images/'),
        ),
        migrations.AlterField(
            model_name='message',
            name='content',
            field=models.TextField(),
        ),
    ]
