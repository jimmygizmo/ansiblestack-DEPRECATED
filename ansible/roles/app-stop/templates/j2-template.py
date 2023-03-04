from jinja2 import Template, StrictUndefined


# NOTE: Ansible uses StrictUndefined by default, meaning all variables must be defined. None may be undefined.


template = "Application: {{ appname }}    State: {{ appstate }}"

data = {
    "appname": "AppOne",
    "appstate": "initializing",
}

j2_template = Template(template, undefined=StrictUndefined)

