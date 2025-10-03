FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    WORKDIR=/usr/local/src/app

WORKDIR $WORKDIR

COPY pyproject.toml uv.lock ./

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-install-project

COPY world_cup_stats $WORKDIR/world_cup_stats

FROM python:3.12-slim

ENV WORKDIR=/usr/local/src/app
WORKDIR $WORKDIR

COPY --from=builder $WORKDIR $WORKDIR

ENV PATH="$WORKDIR/.venv/bin:$PATH"

RUN adduser --disabled-password --gecos '' --home /home/worldcupstatsuser worldcupstatsuser && \
    chown -R worldcupstatsuser $WORKDIR

USER worldcupstatsuser

ENTRYPOINT ["python"]
CMD ["-m", "world_cup_stats.insert_world_cup_stats"]
