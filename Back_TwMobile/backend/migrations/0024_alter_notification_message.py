# Generated by Django 4.2.13 on 2024-06-27 06:39

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backend', '0023_notification'),
    ]

    operations = [
        migrations.AlterField(
            model_name='notification',
            name='message',
            field=models.TextField(),
        ),
    ]
