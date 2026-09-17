# Jinja templates

Implementation of the [Jinja2 template engine](https://jinja.palletsprojects.com/en/stable)(Python) written in D. Templates can be parsed and evaluated at runtime or compile time as needed.

## Installation

## Usage

### Directly use `renderString` or `renderFile`

Render text as is without any variables

```d
renderString("Hello World!"); // Returns "Hello World!"
```

Render text with variables (Option 1 - Pass local variables)

```d
string name = "Jinja";
renderString!(name)("Hello {{ name }}!"); // Returns "Hello Jinja!"
```

Render text with variables (Option 2)

```d
JSONValue data;
data["name"] = "Jinja";
renderString("Hello {{ name }}!", data); // Returns "Hello Jinja!"
```

Render a file without any variables

index.html
```html
<h1>Hello World!</h1>
```

```d
renderFile("index.html");
```

Render file with variables

index.html
```html
<h1>{{ title }}</h1>
```

Option1: Pass local variables

```d
auto title = "Hello Jinja!";
auto content = "....";
renderFile!(title, content)("index.html");
```

Option2: Use `JSONValue` data

```d
JSONValue data;
data["title"] = "Hello Jinja!";
data["content"] = "....";
renderFile("index.html", data);
```

#### Settings

**onMissingkey**

```d
// Default. Returns "Hello !"
renderString("Hello {{ name }}!", data, onMissingkey: MissingKey.empty);
renderFile("index.html", data, onMissingkey: MissingKey.empty);

// Returns "Hello {{ name }}!"
renderString("Hello {{ name }}!", data, onMissingkey: MissingKey.passThrough);
renderFile("index.html", data, onMissingkey: MissingKey.passThrough);

// Raises JinjaException
renderString("Hello {{ name }}!", data, onMissingkey: MissingKey.error);
renderFile("index.html", data, onMissingkey: MissingKey.error);
```

**viewsDirectory**

```d
renderString("Hello {{ name }}!", data, viewsDirectory: "./templates");
renderFile("index.html", data, viewsDirectory: "./templates");
```

### Use single template Jinja instance

```d
auto tmpl = templateFromString("Hello World!");
tmpl.render;
```

```d
auto tmpl = templateFromString("Hello {{ name }}!");
auto name = "Jinja";
tmpl.render!(name);
```

```d
auto tmpl = templateFromString("Hello {{ name }}!");
JSONValue data;
data["name"] = "Jinja";
tmpl.render(data);
```

Render file

```d
auto tmpl = templateFromFile("index.html");
tmpl.render;
```

```d
auto tmpl = templateFromFile("index.html");
auto name = "Jinja";
tmpl.render!(name);
```

```d
auto tmpl = templateFromFile("index.html");
JSONValue data;
data["name"] = "Jinja";
tmpl.render(data);
```

#### Settings

**onMissingkey**

```d
// Default. Returns "Hello !"
auto tmpl1 = templateFromString("Hello {{ name }}!", onMissingkey: MissingKey.empty);
auto tmpl2 = templateFromFile("index.html", onMissingkey: MissingKey.empty);
```

**viewsDirectory**

```d
auto tmpl = templateFromString("Hello {{ name }}!", viewsDirectory: "./templates");
auto tmpl = templateFromFile("index.html", viewsDirectory: "./templates");
```

### Use `Jinja` instance

```d
Jinja view;
view.render!(name)("Hello {{ name }}!");
view.renderString!(name)("Hello {{ name }}!");
view.renderFile!(name)("index.html");
view.render("Hello {{ name }}!", data);
view.renderString("Hello {{ name }}!", data);
view.renderFile("index.html", data);
```

#### Settings

```d
Jinja view;
view.settings.onMissingkey = MissingKey.empty;
view.settings.viewsDirectory = "./views"; // Default
view.renderString("Hello {{ name }}!", data);
```

## Template Syntax

### Variables

The content inside the `{{` and `}}` will be looked up in the given data.

```html
Hello {{ name }}!
```

### Conditions

```html
{% if username == "admin" %}
Welcome Admin!
{% else %}
Welcome!
{% endif %}
```

### Loop

```html
<ul>
    {% for name in names %}
    <li>{{ name }}</li>
    {% endfor %}
</ul>
```

## Using with Serverino

index.html

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ title }}</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css">
  </head>
  <body>
  <section class="section">
    <div class="container">
      <h1 class="title">
      {{ title }}
      </h1>
      <p class="subtitle">
        {{ subtitle }}
      </p>
    </div>
  </section>
  </body>
</html>
```

app.d

```d
/+ dub.sdl:
dependency "serverino" version="~>0.8.1"
dependency "jinja" version="~>0.1.0"
 +/
import jinja;
import serverino;

mixin ServerinoMain;

Jinja view;

static this()
{
    view.settings.viewsDirectory = "./views";
}

void simple(Request request, Output output)
{
    auto title = "Jinja";
    auto subtitle = "Simple Text Template system";
    output ~= view.renderFile!(title, subtitle)("index.html");
}
```

Run

```
dub app.d
```
