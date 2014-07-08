SWIM = YAML-Like-a-Pro.swim
HTML = YAML-Like-a-Pro.html
MARKDOWN = YAML-Like-a-Pro.md
POD = YAML-Like-a-Pro.pod

all: html pod markdown

html:
	swim --to=html --complete=1 --wrap=1 $(SWIM) > $(HTML)

markdown:
	swim --to=md --complete=1 --wrap=1 $(SWIM) > $(MARKDOWN)

pod:
	swim --to=pod --complete=1 --wrap=1 $(SWIM) > $(POD)

