.PHONY: pdf clean

pdf:
	docker compose run --rm latex

clean:
	docker compose run --rm latex latexmk -C
