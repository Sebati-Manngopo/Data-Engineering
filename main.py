import json
from datetime import datetime
import pandas as pd
import requests

city_name = input("Please enter name of your city\n")
base_url = "https://api.openweathermap.org/data/2.5/weather?q="

"""f = open("credentials.txt", "rt")
api_key = f.read()
f.close()"""

with open("credentials.txt", 'r') as f:
    api_key = f.read()

full_url = base_url + city_name + "&APPID=" + api_key


def kelvin_to_celsius(temp_in_kelvin):
    temp_in_celsius = (temp_in_kelvin - 273.15)
    return temp_in_celsius


def etl_weather_data(url):
    r = requests.get(url)
    data = r.json()
    # print(data)

    city = data["name"]
    weather_description = data["weather"][0]['description']
    temp_fahrenheit = kelvin_to_celsius(data["main"]["temp"])
    feels_like_fahrenheit = kelvin_to_celsius(data["main"]["feels_like"])
    min_temp_fahrenheit = kelvin_to_celsius(data["main"]["temp_min"])
    max_temp_fahrenheit = kelvin_to_celsius(data["main"]["temp_max"])
    pressure = data["main"]["pressure"]
    humidity = data["main"]["humidity"]
    wind_speed = data["wind"]["speed"]
    time_of_record = datetime.fromtimestamp(data['dt'] + data['timezone'])
    sunrise_time = datetime.fromtimestamp(data['sys']['sunrise'] + data['timezone'])
    sunset_time = datetime.fromtimestamp(data['sys']['sunset'] + data['timezone'])

    transformed_data = {"City": city,
                        "Description": weather_description,
                        "Temperature (F)": temp_fahrenheit,
                        "Feels Like (F)": feels_like_fahrenheit,
                        "Minimum Temp (F)": min_temp_fahrenheit,
                        "Maximum Temp (F)": max_temp_fahrenheit,
                        "Pressure": pressure,
                        "Humidity": humidity,
                        "Wind Speed": wind_speed,
                        "Time of Record": time_of_record,
                        "Sunrise (Local Time)": sunrise_time,
                        "Sunset (Local Time)": sunset_time
                        }

    transformed_data_list = [transformed_data]
    df_data = pd.DataFrame(transformed_data_list)
    # print(df_data)

    df_data.to_csv("current_weather_data.csv", index=False)


if __name__ == '__main__':
    etl_weather_data(full_url)
