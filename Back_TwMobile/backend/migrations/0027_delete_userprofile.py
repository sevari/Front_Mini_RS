# Generated by Django 4.2.13 on 2024-06-27 11:29

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('backend', '0026_alter_userprofile_options_alter_userprofile_email_and_more'),
    ]

    operations = [
        migrations.DeleteModel(
            name='UserProfile',
        ),
    ]