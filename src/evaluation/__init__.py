"""ScholarBot evaluation module — dataset loaders and predict_fn helpers.

Used by the evaluation notebook. See docs/EVAL_GUIDE.md for the workflow.
"""

from inference import research


def load_deepsearchqa(n: int = 25, seed: int = 42) -> list[dict]:
    """Load and sample DeepSearchQA, transformed to MLflow eval schema.

    Returns a list of dicts with {inputs, expectations, tags} ready for
    mlflow.genai.evaluate().
    """
    from datasets import load_dataset

    from typing import cast

    from datasets import Dataset

    hf_ds = cast(Dataset, load_dataset("google/deepsearchqa")["eval"])
    samples = hf_ds.shuffle(seed=seed).select(range(n))

    return [
        {
            "inputs": {"question": row["problem"]},
            "expectations": {
                "answer": row["answer"],
                "answer_type": row["answer_type"],
            },
            "tags": {"category": row["problem_category"]},
        }
        for row in cast(list[dict], samples)
    ]


def make_predict_fn(variant: str = "v1-baseline"):
    """Create a predict_fn for mlflow.genai.evaluate().

    Returns an async function that MLflow auto-detects and handles.
    The variant is bound via closure.
    """

    async def predict_fn(question: str) -> str:
        return await research(question, variant=variant)

    return predict_fn
