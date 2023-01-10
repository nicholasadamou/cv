# cv

This repository is used to host, build, and deploy my curriculum vitae (CV).

## Requirements

To build the CV, you will need the following:

* [Docker](https://www.docker.com/)

## Build

To build the CV, run the following command:

```bash
./build-cv.sh
```
This will build the CV using the `Dockerfile` in the root of the repository. The output will be a PDF file named `cv.pdf` and a webpage named `index.html` in the [`docs`](docs) directory.

## Preview

You can preview the CV by running the following command:

```bash
python3 -m http.server
```

Then, navigate to [http://localhost:8000/docs](http://localhost:8000/docs) to view the CV.

## License

© Nicholas Adamou.

It is free software, and may be redistributed under the terms specified in the [LICENSE](LICENSE) file.
