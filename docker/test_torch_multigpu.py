import torch
import torch.nn as nn
import torch.optim as optim

class SimpleNet(nn.Module):
    def __init__(self):
        super(SimpleNet, self).__init__()
        self.fc = nn.Linear(12288, 4096)  # An example layer

    def forward(self, x):
        return self.fc(x)

if torch.cuda.device_count() > 1:
    print(f"Using {torch.cuda.device_count()} GPUs!")
    model = SimpleNet()
    model = nn.DataParallel(model)
else:
    print("Using only one GPU.")
    model = SimpleNet()

model.to('cuda')

input = torch.randn(4096, 12288).to('cuda')

output = model(input)
print(output)

