FROM scratch

WORKDIR /home/agent

COPY . .agents/skills
COPY . .claude/skills
