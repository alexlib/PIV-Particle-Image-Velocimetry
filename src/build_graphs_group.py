import numpy as np
import matplotlib.pyplot as plt

def build_graphs_group(data):
    """
    build_graphs_group Visualization of comparison results for all scenarios
    Allows visualizing a dynamic number of scenarios
    """
    
    N, P = data.shape[:2]
    x = np.arange(1, N + 1)

    # Root mean square deviation
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
    for p in range(P):
        ax1.plot(x, data[:, p, 0], linewidth=2.0)
    ax1.set_title('Root Mean Square Deviation')
    ax1.grid(True)
    ax1.set_xlabel('Image Pair Number', fontweight='bold')
    ax1.set_ylabel('RMS, pixels', fontweight='bold')

    # Maximum deviation
    for p in range(P):
        ax2.plot(x, data[:, p, 1], linewidth=2.0)
    ax2.set_title('Maximum Deviation')
    ax2.grid(True)
    ax2.set_xlabel('Image Pair Number', fontweight='bold')
    ax2.set_ylabel('Max, pixels', fontweight='bold')

    # Create legend
    legend_text = [f'processing {p + 1}' for p in range(P)]
    ax1.legend(legend_text, loc='best')
    ax2.legend(legend_text, loc='best')

    plt.tight_layout()
    plt.show()

# Example usage
# data = np.random.rand(10, 5, 2)  # Example data
# build_graphs_group(data)