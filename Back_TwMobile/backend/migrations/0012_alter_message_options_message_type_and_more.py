# Generated by Django 4.2.13 on 2024-06-23 15:57

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backend', '0011_alter_message_options_remove_message_image_url_and_more'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='message',
            options={},
        ),
        migrations.AddField(
            model_name='message',
            name='type',
            field=models.CharField(choices=[('text', 'Text'), ('image', 'Image')], default='text', max_length=10),
        ),
        migrations.AlterField(
            model_name='message',
            name='content',
            field=models.TextField(blank=True, null=True),
        ),
    ]
