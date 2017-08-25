module owlchain.meterics.samplingInterface;

import owlchain.meterics.snapshot;

enum SampleType
{
    kUniform,
    kBiased
};

interface SamplingInterface
{
    Snapshot getSnapshot();
}
