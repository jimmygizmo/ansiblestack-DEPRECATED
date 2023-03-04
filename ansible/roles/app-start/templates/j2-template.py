from jinja2 import Template, StrictUndefined


# NOTE: Ansible uses StrictUndefined by default, meaning all variables must be defined. None may be undefined.


template = """

Application: {{ appname }}
State: {{ appstate }}

{# This is a comment in the template to assist users. Comments are not rendered. -#}

"""

data = {
    "appname": "AppOne",
    "appstate": "initializing",
}

j2_template = Template(template, undefined=StrictUndefined)

