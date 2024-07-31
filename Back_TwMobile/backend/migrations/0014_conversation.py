# Generated by Django 4.2.13 on 2024-06-25 11:12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backend', '0013_message_file_alter_message_content_and_more'),
    ]

    operations = [
        migrations.CreateModel(
            name='Conversation',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('recipient_id', models.IntegerField()),
                ('recipient_name', models.CharField(max_length=100)),
                ('last_message', models.TextField(blank=True, null=True)),
                ('last_message_time', models.DateTimeField(blank=True, null=True)),
            ],
        ),
    ]
