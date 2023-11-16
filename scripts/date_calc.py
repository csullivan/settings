import sys
import click

"""
Use with:
GIT_DATE=$(python3 ../date_calc.py) && GIT_COMMITTER_DATE="$GIT_DATE" && GIT_AUTHOR_DATE="$GIT_DATE" && git commit --amend --no-edit --date="$GIT_DATE
"""

from datetime import datetime, timedelta


@click.command()
@click.option(
    "--hours-ago", default=0, help="Number of hours to subtract from current time"
)
def main(hours_ago):
    new_date = datetime.now() - timedelta(hours=hours_ago)
    print(new_date.strftime("%a %b %d %H:%M:%S %Y %z"))


if __name__ == "__main__":
    main()
