# Generated by Django 5.0.6 on 2024-05-25 15:20

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='student',
            name='student_class',
            field=models.IntegerField(max_length=20),
        ),
    ]
